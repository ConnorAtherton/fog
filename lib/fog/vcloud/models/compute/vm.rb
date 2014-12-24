require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Vm < Model
        identity  :id

        attribute :vapp_id
        attribute :vapp_name
        attribute :name
        attribute :type
        attribute :href
        attribute :status
        attribute :operating_system
        attribute :ip_address
        attribute :cpu, :type => :integer
        attribute :memory, :type => :integer
        attribute :hard_disks, :aliases => :disks

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

        def tags
          requires :id
          service.tags(:vm => self)
        end

        def customization
          requires :id
          data = service.get_vm_customization(id).body
          service.vm_customizations.new(data)
        end

        # todo
        # def network
        #   requires :id
        #   data = service.get_vm_network(id).body
        #   service.vm_networks.new(data)
        # end

        # def disks
        #   requires :id
        #   service.disks(:vm => self)
        # end

        # def memory=(new_memory)
        #   has_changed = ( memory != new_memory.to_i )
        #   not_first_set = !memory.nil?
        #   attributes[:memory] = new_memory.to_i
        #   if not_first_set && has_changed
        #     response = service.put_memory(id, memory)
        #     service.process_task(response.body)
        #   end
        # end

        # def cpu=(new_cpu)
        #   has_changed = ( cpu != new_cpu.to_i )
        #   not_first_set = !cpu.nil?
        #   attributes[:cpu] = new_cpu.to_i
        #   if not_first_set && has_changed
        #     response = service.put_cpu(id, cpu)
        #     service.process_task(response.body)
        #   end
        # end

        def ready?
          reload
          status == 'on'
        end

        def vapp
          # get_by_metadata returns a vm collection where every vapp parent is orpahn
          collection.vapp ||= service.vapps.get(vapp_id)
        end
      end
    end
  end
end
