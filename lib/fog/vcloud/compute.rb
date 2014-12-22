require 'fog/vcloud/core'

module Fog
  module Vcloud
    class Model < Fog::Model
      attr_accessor :loaded
      alias_method :loaded?, :loaded

      def reload
        instance = super
        @loaded = true
        instance
      end

      def load_unless_loaded!
        unless @loaded
          reload
        end
      end

      def link_up
        load_unless_loaded!
        self.links.find{|l| l[:rel] == 'up' }
      end

      def self.has_up(item)
        class_eval <<-EOS, __FILE__,__LINE__
          def #{item}
            load_unless_loaded!
            service.get_#{item}(link_up[:href])
          end
        EOS
      end
    end
  end
end

module Fog
  module Compute
    class Vcloud < Fog::Service
      BASE_PATH   = 'api/compute/api'
      VERSION = '5.7'
      DEFAULT_HOST_URL = "beta2014.vchs.vmware.com"
      PORT   = 443
      SCHEME = 'https'

      attr_writer :default_vdc_uri

      requires   :vcloud_username, :vcloud_password, :vcloud_org, :vcloud_host
      recognizes :vcloud_port, :vcloud_scheme, :vcloud_path, :vcloud_version, :vcloud_base_path
      recognizes :provider # remove post deprecation

      model_path 'fog/vcloud/models/compute'
      model :catalog
      collection :catalogs
      model :catalog_item
      model :catalog_items
      # model :ip
      #collection :ips
      #model :network
      #collection :networks
      #model :server
      #collection :servers
      #model :task
      #collection :tasks
      model :vapp
      collection :vapps
      model :vdc
      collection :vdcs
      model :organization
      collection :organizations
      #model :tag
      #collection :tags

      request_path 'fog/vcloud/requests/compute'
      #request :clone_vapp
      #request :configure_network
      #request :configure_network_ip
      #request :configure_vapp
      #request :configure_vm_memory
      #request :configure_vm_cpus
      #request :configure_org_network
      #request :configure_vm_name_description
      #request :configure_vm_disks
      #request :configure_vm_password
      #request :configure_vm_network
      #request :get_customization_options
      #request :get_network_ip
      #request :get_network_ips
      #request :get_network_extensions
      #request :get_task_list
      #request :get_vapp_template
      #request :get_vm_disks
      #request :get_vm_memory
      #request :configure_vm_customization_script

      # for me to do
      #request :instantiate_vapp_template
      request :login
      #request :power_off
      #request :power_on
      #request :power_reset
      #request :power_shutdown
      #request :undeploy
      #request :get_metadata
      #request :delete_metadata
      #request :configure_metadata
      #request :delete_vapp
      #request :get_catalog_item
      # request :get_catalogs

      # All my additions
      request :get_organizations
      request :get_organization

      class Mock
        def initialize(options={})
          Fog::Mock.not_implemented
        end
      end

      class Real
        attr_reader :version

        def self.basic_request(*args); end

        def initialize(options = {})
          version = (options[:vcloud_api_version] || VERSION)

          @connection = nil
          @connection_options = options[:connection_options] || {}
          @persistent = options[:persistent] || false
          @vcloud_auth_token = nil

          @username   = options[:vcloud_username]
          @password   = options[:vcloud_password]
          @org        = options[:vcloud_org]

          @raw_host   = options[:vcloud_host]
          @host       = slice_from_end(options[:vcloud_host], 4)

          @base_path  = options[:vcloud_base_path]   || BASE_PATH
          @version    = options[:vcloud_version]     || VERSION
          @port       = options[:vcloud_port]        || PORT
          @scheme     = options[:vcloud_scheme]      || SCHEME
          @default_host = DEFAULT_HOST_URL
        end

        def slice_from_end(str, amount = 1)
          amount = amount * -1
          str.split("/")[0...amount].join("/") + "/"
        end

        def add_id_from_href!(data={})
          data[:id] = data[:href].split('/').last
          data
        end

        def reload
          @connections.reset
        end

        def default_organization_uri
          @default_organization_uri ||= connection.organizations.first.href
        end

        def default_vdc_href
          if @vdc_href.nil?
            org = organizations.first
            vdc = get_organization(org.href).links.find { |item| item[:type] == 'application/vnd.vmware.vcloud.vdc+xml'}
            @vdc_href = vdc[:href]
          end

          @vdc_href
        end

        # login handles the auth, but we just need the vchs-authorization header
        def do_login
          puts "Trying to log in..."
          response = login
          # If we got the token back we want to keep it for future requests
          @vcloud_auth_token = response.headers["x-vcloud-authorization"]
        end

        # If the cookie isn't set, do a get_organizations call to set it
        # and try the request.
        # If we get an Unauthorized error, we assume the token expired, re-auth and try again
        def request(params)
          puts "auth token is: #{@vcloud_auth_token}"
          do_login if @vcloud_auth_token.nil?

          begin
            do_request(params)
          rescue Excon::Errors::Unauthorized
            puts "The token has expired so generate a new one"
            do_login
            do_request(params)
          end
        end

        def base_path_url(base_path = nil)
          "#{@scheme}://#{@host}#{@base_path}"
        end

        private

        def ensure_uri(uri)
          uri.is_a?(String) ? URI.parse(URI.encode(uri.strip)) : uri
        end

        # Don't need to  set the cookie for these or retry them if the cookie timed out
        def unauthenticated_request(params)
          do_request(params)
        end

        def base_url
          "#{@scheme}://#{@host}#{@path}"
        end

        # Use this to set the Authorization header for login
        def authorization_header
          "Basic #{Base64.encode64("#{@username}@#{@org}:#{@password}").delete("\r\n")}"
        end

        def oauth_header
          "Bearer #{@vcloud_auth_token}"
        end

        # TODO Please return json (not available with this api yet)
        def default_header_params
          # "application/json;version=#{VERSION};"
          "application/*+xml;version=#{VERSION};"
        end

        def get_path(params)
          return nil if params[:path].nil?

          if params[:override_path] == true
            path = params[:path]
          else
            path = "#{@base_path}/#{params[:path]}"
          end

          path
        end

        # Actually do the request
        def do_request(params)
          @connection ||= Fog::XML::Connection.new(@host, @persistent, @connection_options)
          headers = {
            'Accept' => "application/*+xml;version=#{VERSION}",
            'x-vcloud-authorization' => @vcloud_auth_token
          }

          headers.merge!(params[:headers]) if params[:headers]
          path = get_path params

          # binding.pry

          request_object = {
            :body     => params[:body] || '',
            :expects  => params[:expects] || 200,
            :headers  => headers,
            :method   => params[:method] || 'GET',
            :path     => path || ''
          }

          response = @connection.request(request_object)

          # Parse the response body into a hash
          unless response.body.empty?
            document = Fog::ToHashDocument.new
            parser = Nokogiri::XML::SAX::PushParser.new(document)
            parser << response.body
            parser.finish
            response.body = document.body
          end

          response
        end
      end
    end
  end
end
