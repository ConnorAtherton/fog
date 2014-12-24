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

        def item_list
          entities = vapp.children
          return [] if entities == ""

          if entities.is_a?(Hash) && entities[:type] == "application/vnd.vmware.vcloud.vm+xml"
            return [service.add_id_from_href!(entities)]
          end

          vms = entities.select { |re| re[:type] == "application/vnd.vmware.vcloud.vm+xml" }
          vms.each {|v| service.add_id_from_href!(v) }
          vms
        end

        def get_by_id(id)
          item = item_list.find {|vm| vm[:id] == id}
          item
        end
      end
    end
  end
end
