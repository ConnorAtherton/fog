require 'fog/core/collection'
require 'fog/vcloud/models/compute/vdc'

module Fog
  module Compute
    class Vcloud
      class Vdcs < Collection
        model Fog::Compute::Vcloud::Vdc

        attribute :organization

        def item_list
          data = service.get_organization(organization.id).body
          items = data[:Link].select { |link| link[:type] == "application/vnd.vmware.vcloud.vdc+xml" }
          items.each {|v| service.add_id_from_href!(v) }
          items
        end

        def get_by_id(id)
          vdc = service.get_vdc(id)
          return nil if vdc.nil?
          service.add_id_from_href!(vdc.data[:body])
        end
      end
    end
  end
end
