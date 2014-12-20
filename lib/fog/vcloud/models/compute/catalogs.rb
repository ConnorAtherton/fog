require 'fog/core/collection'
require 'fog/vcloud/models/compute/catalog'

module Fog
  module Compute
    class Vcloud
      class Catalogs < Collection
        model Fog::Compute::Vcloud::Catalog

        attribute :organization_uri

        def all
          org_uri = self.organization_uri || service.default_organization_uri
          data = service.get_organization(org_uri).links.select { |link| link[:type] == "application/vnd.vmware.vcloud.catalog+xml" }
        end

        def get(uri)
          service.get_catalog(uri)
        rescue Fog::Errors::NotFound
          nil
        end

        def item_by_name(name)
          res = nil
          items = all.map { |catalog| catalog.catalog_items }
          items.each do |i|
            i.map do |ii|
              res = ii if ii.name == name
            end
          end
          res
        end
      end
    end
  end
end
