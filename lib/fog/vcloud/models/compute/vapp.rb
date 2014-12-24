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

        def undeploy(action='powerOff')
          response = service.post_undeploy_vapp(id, :UndeployPowerAction => action)
          service.process_task(response.body)
        end

        # Power off all VMs in the vApp.
        def power_off
          requires :id
          response = service.post_power_off_vapp(id)
          service.process_task(response.body)
        end

        # Power on all VMs in the vApp.
        def power_on
          requires :id
          response = service.post_power_on_vapp(id)
          service.process_task(response.body)
        end

        # Reboot all VMs in the vApp.
        def reboot
          requires :id
          response = service.post_reboot_vapp(id)
          service.process_task(response.body)
        end

        # Reset all VMs in the vApp.
        def reset
          requires :id
          response = service.post_reset_vapp(id)
          service.process_task(response.body)
        end

        # Shut down all VMs in the vApp.
        def shutdown
          requires :id
          response = service.post_shutdown_vapp(id)
          service.process_task(response.body)
        end

        # Suspend all VMs in the vApp.
        def suspend
          requires :id
          response = service.post_suspend_vapp(id)
          service.process_task(response.body)
        end

        def destroy
          requires :id
          response = service.delete_vapp(id)
          service.process_task(response.body)
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
