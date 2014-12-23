require 'fog/core/collection'
require 'fog/vcloud/models/compute/vdc'

module Fog
  module Compute
    class Vcloud
      class Vdcs < Collection
        model Fog::Compute::Vcloud::Vdc

        attribute :organization

        def all
          data = service.get_organization(organization.id).body
          items = data[:Link].select { |link| link[:type] == "application/vnd.vmware.vcloud.vdc+xml" }
          items.each {|v| service.add_id_from_href!(v) }
          load(items)
        end

        def get_by_id(id)
          vdc = service.get_vdc(id).data[:body]
          new(vdc)
        end
      end
    end
  end
end
