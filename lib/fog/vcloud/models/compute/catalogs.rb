require 'fog/core/collection'
require 'fog/vcloud/models/compute/catalog'

module Fog
  module Compute
    class Vcloud
      class Catalogs < Collection
        model Fog::Compute::Vcloud::Catalog

        attribute :organization

        def item_list
          catalogs = organization.links.select { |link| link[:type] == "application/vnd.vmware.vcloud.catalog+xml" }
          catalogs.each {|c| service.add_id_from_href!(c) }
          catalogs
        end

        def get_by_id(id)
          service.get_catalog(id).data[:body]
        end
      end
    end
  end
end
