module Fog
  module Compute
    class Vcloud
      class Real
        def instantiate_vapp_template(vapp_name, template_id, options = {})
          params  = populate_uris(options.merge(:vapp_name => vapp_name, :template_id => template_id))
          data    = generate_instantiate_vapp_template_request(params)
          headers = {
           'Accept' => "application/vnd.vmware.vcloud.vApp+xml",
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
          attrs = {
            'xmlns' => 'http://www.vmware.com/vcloud/v1.5',
            'xmlns:ovf' => 'http://schemas.dmtf.org/ovf/envelope/1',
            :name => vapp_name
          }
          attrs[:deploy] = options[:deploy] if options.key?(:deploy)
          attrs[:powerOn] = options[:powerOn] if options.key?(:powerOn)

          body = Nokogiri::XML::Builder.new do
            InstantiateVAppTemplateParams(attrs) {
              if options.key?(:Description)
                Description options[:Description]
              end
              if instantiation_params = options[:InstantiationParams]
                InstantiationParams {
                  if section = instantiation_params[:LeaseSettingsSection]
                    LeaseSettingsSection {
                      self['ovf'].Info 'Lease settings section'
                      if section.key?(:DeploymentLeaseInSeconds)
                        DeploymentLeaseInSeconds section[:DeploymentLeaseInSeconds]
                      end
                      if section.key?(:StorageLeaseInSeconds)
                        StorageLeaseInSeconds section[:StorageLeaseInSeconds]
                      end
                      if section.key?(:DeploymentLeaseExpiration)
                        DeploymentLeaseExpiration section[:DeploymentLeaseExpiration].strftime('%Y-%m-%dT%H:%M:%S%z')
                      end
                      if section.key?(:StorageLeaseExpiration)
                        StorageLeaseExpiration section[:StorageLeaseExpiration].strftime('%Y-%m-%dT%H:%M:%S%z')
                      end
                    }
                  end
                  if section = instantiation_params[:NetworkConfigSection]
                    NetworkConfigSection {
                      self['ovf'].Info 'Configuration parameters for logical networks'
                      if network_configs = section[:NetworkConfig]
                        network_configs = [network_configs] if network_configs.is_a?(Hash)
                        network_configs.each do |network_config|
                          NetworkConfig(:networkName => network_config[:networkName]) {
                            if configuration = network_config[:Configuration]
                              Configuration {
                                ParentNetwork(configuration[:ParentNetwork])
                                FenceMode configuration[:FenceMode]
                              }
                            end
                          }
                        end
                      end
                    }
                  end
                }
              end
              Source(:href => "#{end_point}vAppTemplate/#{vapp_template_id}")
              if options.key?(:IsSourceDelete)
                IsSourceDelete options[:IsSourceDelete]
              end
              if options.key?(:AllEULAsAccepted)
                AllEULAsAccepted options[:AllEULAsAccepted]
              end
            }
          end.to_xml

          binding.pry
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
