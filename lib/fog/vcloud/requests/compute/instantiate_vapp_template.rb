module Fog
  module Compute
    class Vcloud
      class Real
        def instantiate_vapp_template(vapp_name, template_id, options = {})
          params  = populate_uris(options.merge(:vapp_name => vapp_name, :template_id => template_id))
          data    = generate_instantiate_vapp_template_request(params)
          headers = {
           'Content-Type' => 'application/vnd.vmware.vcloud.instantiateVAppTemplateParams+xml'
          }
          binding.pry

          res = request({
            body: data,
            expects: 201,
            headers: headers,
            method: "POST",
            path: "vdc/#{params[:vdc_id]}/action/instantiateVAppTemplate"
          })

          binding.pry
        end

        private

        def xmlns
          {
            'xmlns'     => "http://www.vmware.com/vcloud/v1.5",
            "xmlns:ovf" => "http://schemas.dmtf.org/ovf/envelope/1",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema"
          }
        end

        def populate_uris(options = {})
          options[:vdc_id] || raise("vdc_id option is required")
          options[:vdc_uri] =  vdc_end_point(options[:vdc_id])
          options[:network_uri] = network_end_point(options[:network_id]) if options[:network_id]
          options[:template_uri] = vapp_template_end_point(options[:template_id]) || raise("template_id option is required")
          options
        end

        def generate_instantiate_vapp_template_request(options)
          xml = Builder::XmlMarkup.new
          xml.InstantiateVAppTemplateParams(xmlns.merge!(:name => options[:vapp_name], :"xml:lang" => "en", :"power_on" => true, :"deploy" => true)) {
            xml.Description(options[:description])
            xml.InstantiationParams {
              if options[:network_uri]
                # TODO - implement properly
                xml.NetworkConfigSection {
                  xml.tag!("ovf:Info"){ "Configuration parameters for logical networks" }
                  xml.NetworkConfig("networkName" => options[:network_name]) {
                    # xml.NetworkAssociation( :href => options[:network_uri] )
                    xml.Configuration {
                      xml.ParentNetwork("name" => options[:network_name], "href" => options[:network_uri])
                      xml.FenceMode("bridged")
                    }
                  }
                }
              end
            }
            # The template
            xml.Source(:href => options[:template_uri])
            xml.AllEULAsAccepted("true")
          }
        end

        def vdc_end_point(vdc_id = nil)
          default_full_host + ( vdc_id ? "vdc/#{vdc_id}" : "vdc" )
        end

        def network_end_point(network_id = nil)
          default_full_host + ( network_id ? "network/#{network_id}" : "network" )
        end

        def vapp_template_end_point(vapp_template_id = nil)
          default_full_host + ( vapp_template_id ? "vAppTemplate/#{vapp_template_id}" : "vAppTemplate" )
        end
      end
    end
  end
end
