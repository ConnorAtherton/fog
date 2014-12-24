require 'fog/core/collection'
require 'fog/vcloud/models/compute/vapp'

module Fog
  module Compute
    class Vcloud
      class Vapps < Collection
        model Fog::Compute::Vcloud::Vapp

        attribute :href
        attribute :vdc

        def item_list
          entities = vdc.resource_entities
          return nil if entities == ""
          return [service.add_id_from_href!(entities)] if entities.is_a?(Hash)

          vapps = vdc.resource_entities.select { |re| re[:type] == "application/vnd.vmware.vcloud.vApp+xml" }
          vapps.each {|v| service.add_id_from_href!(v) }
          vapps
        end

        def get_by_id(id)
          data = service.get_vapp(id).data[:body]
          service.add_id_from_href!(data)
          data
        end
      end
    end
  end
end
