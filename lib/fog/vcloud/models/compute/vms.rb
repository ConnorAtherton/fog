require 'fog/core/collection'
require 'fog/vcloud/models/compute/vm'

module Fog
  module Compute
    class Vcloud
      class Vms < Collection
        model Fog::Compute::Vcloud::Vm

        identity  :id
        attribute :vapp
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

        def all
          entities = vapp.children
          return [] if entities == ""

          if entities.is_a?(Hash) && entities[:type] == "application/vnd.vmware.vcloud.vm+xml"
            return [new(service.add_id_from_href!(entities))]
          end

          vms = entities.select { |re| re[:type] == "application/vnd.vmware.vcloud.vm+xml" }
          vms.each {|v| service.add_id_from_href!(v) }
          load(vms)
        end

        def get_by_id(id)
          all_vms = all
          return "" if all_vms == ""

          if all_vms.is_a?(Hash) && all_vms[:type] == "application/vnd.vmware.vcloud.vm+xml"
            return new(service.add_id_from_href!(all_vms))
          end

          item = all_vms.find {|vm| vm[:id] == id}
          new(item)
        end
      end
    end
  end
end
