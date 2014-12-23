require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Vapp < Model
        identity :href, :aliases => :Href
        attribute :links, :aliases => :Link, :type => :array
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :name
        attribute :id
        attribute :type
        attribute :status
        attribute :description, :aliases => :Description
        attribute :deployed, :type => :boolean
        attribute :children, :aliases => :Children, :squash => :Vm
        attribute :lease_settings, :aliases => :LeaseSettingsSection
        attribute :network_configs, :aliases => :NetworkConfigSection

        def vms
          requires :id
          service.vms(:vapp => self)
        end

        def tags
          requires :id
          service.tags(:vapp => self)
        end

        def custom_fields
          requires :id
          service.custom_fields(:vapp => self)
        end

        def ready?
          reload_status # always ensure we have the correct status
          status != '0'
        end

        private
        def reload_status
          vapp = service.get_vapp(id)
          self.status = vapp.status
        end
      end
    end
  end
end
