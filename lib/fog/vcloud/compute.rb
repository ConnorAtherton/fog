require 'fog/vcloud/core'
require 'json'

# Alias json module to avoid name conflicts
RJSON = JSON

module Fog
  module Vcloud
    class Collection < Fog::Collection
      def load(objects)
        objects = [ objects ] if objects.is_a?(Hash)
        super
      end

      def check_href!(opts = {})
        self.href = service.default_vdc_href unless href
        unless href
          if opts.is_a?(String)
            t = Hash.new
            t[:parent] = opts
            opts = t
          end
          msg = ":href missing, call with a :href pointing to #{if opts[:message]
                  opts[:message]
                elsif opts[:parent]
                  "the #{opts[:parent]} whos #{self.class.to_s.split('::').last.downcase} you want to enumerate"
                else
                  "the resource"
                end}"
          raise Fog::Errors::Error.new(msg)
        end
      end
    end
  end
end

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
  module Vcloud
    class Compute < Fog::Service
      BASE_PATH   = '/api'
      VERSION = '5.7'
      DEFAULT_HOST_URL = "beta2014.vchs.vmware.com"
      PORT   = 443
      SCHEME = 'https'

      attr_writer :default_vdc_uri

      requires   :vcloud_username, :vcloud_password
      recognizes :vcloud_port, :vcloud_scheme, :vcloud_path, :vcloud_version, :vcloud_base_path
      recognizes :provider # remove post deprecation

      model_path 'fog/vcloud/models/compute'
      model :catalog
      collection :catalogs
      model :catalog_item
      model :catalog_items
      model :ip
      collection :ips
      model :network
      collection :networks
      model :server
      collection :servers
      model :task
      collection :tasks
      model :vapp
      collection :vapps
      model :vdc
      collection :vdcs
      model :organization
      collection :organizations
      model :tag
      collection :tags

      request_path 'fog/vcloud/requests/compute'
      request :clone_vapp
      request :configure_network
      request :configure_network_ip
      request :configure_vapp
      request :configure_vm_memory
      request :configure_vm_cpus
      request :configure_org_network
      request :configure_vm_name_description
      request :configure_vm_disks
      request :configure_vm_password
      request :configure_vm_network
      request :delete_vapp
      request :get_catalog_item
      request :get_customization_options
      request :get_network_ip
      request :get_network_ips
      request :get_network_extensions
      request :get_task_list
      request :get_vapp_template
      request :get_vm_disks
      request :get_vm_memory
      request :instantiate_vapp_template
      request :login
      request :power_off
      request :power_on
      request :power_reset
      request :power_shutdown
      request :undeploy
      request :get_metadata
      request :delete_metadata
      request :configure_metadata
      request :configure_vm_customization_script

      # Added for the new API
      model :plan
      collection :plans

      request :get_plans
      request :get_instances
      request :get_organizations

      class Mock
        def initialize(options={})
          Fog::Mock.not_implemented
        end
      end

      class Real
        attr_reader :version

        def self.basic_request(*args); end

        def initialize(options = {})
          # force version
          version = (options[:vcloud_api_version] || VERSION)

          @connection = nil
          @connection_options = options[:connection_options] || {}
          @persistent = options[:persistent]
          @vcloud_auth_token = nil

          @username  = options[:vcloud_username]
          @password  = options[:vcloud_password]
          @connection_options = options[:connection_options] || {}
          @persistent = options[:persistent]  || false
          @base_path = options[:vcloud_base_path]   || Fog::Vcloud::Compute::BASE_PATH
          @version   = options[:vcloud_version]     || Fog::Vcloud::Compute::VERSION
          @port      = options[:vcloud_port]        || Fog::Vcloud::Compute::PORT
          @scheme    = options[:vcloud_scheme]      || Fog::Vcloud::Compute::SCHEME
          @host      = Fog::Vcloud::Compute::DEFAULT_HOST_URL
        end

        def reload
          @connections.each_value { |k,v| v.reset if v }
        end

        def default_organization_uri
          @default_organization_uri ||= organizations.first.href
          @default_organization_uri
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
          response = login
          # If we got the token back we want to keep it for future requests
          @vcloud_auth_token = response.headers["vchs-authorization"]
        end

        def xmlns; end

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
          "Basic #{Base64.encode64("#{@username}:#{@password}").delete("\r\n")}"
        end

        def oauth_header
          "Bearer #{@vcloud_auth_token}"
        end

        # Please return json
        def default_header_params
          "application/json;version=#{VERSION};"
        end

        # Actually do the request
        def do_request(params)
          @connection ||= Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)

          # Set headers to appropriate values
          headers = {
            'Content-Type' => default_header_params
          }

          headers.merge!(params[:headers])

          if params[:path]
            if params[:override_path] == true
              path = params[:path]
            else
              path = "#{@base_path}/#{params[:path]}"
            end
          else
            path = "#{@base_path}"
          end

          # Include the oauth token in all subsequence requests
          if @vcloud_auth_token
            puts "Already authorized"
            puts @vcloud_auth_token
            headers['Authorization'] = oauth_header
          end

          puts "-" * 3
          puts headers
          puts path
          puts "-" * 3

          response = @connection.request({
            :body     => params[:body] || '',
            :expects  => params[:expects] || 200,
            :headers  => headers,
            :method   => params[:method] || 'GET',
            :path     => path
          })

          # Parse the response body into a hash
          response.body = RJSON.parse(response.body) unless response.body.empty?
          response
        end
      end

      def self.item_requests(*types)
        types.each {|t| item_request(t)}
      end

      def self.item_request(type)
        Fog::Vcloud::Compute::Real.class_eval <<-EOS, __FILE__,__LINE__
          def get_#{type}(uri)
            Fog::Vcloud::Compute::#{type.to_s.capitalize}.new(
              self.request(basic_request_params(uri)).body.merge(
                :service => self,
                :collection => Fog::Vcloud::Compute::#{type.to_s.capitalize}s.new(
                  :service => self
                )
              )
            )
          end
        EOS
      end

      item_requests :organization, :vdc, :network, :vapp, :server, :catalog, :task
    end
  end
end
