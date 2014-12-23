require 'fog/core/collection'
require 'fog/vcloud/models/compute/catalog_item'

module Fog
  module Compute
    class Vcloud
      class CatalogItems < Collection
        model Fog::Compute::Vcloud::CatalogItem

        attribute :cat

        def all
          catalog = service.get_catalog(cat.id)
          items = catalog.body[:CatalogItems]
          load(items[:CatalogItem]) if items.size > 0
        end

        def get_by_id(id)
          data = service.get_catalog_item(id)
          data.body ? new(data.body) : nil
        end
      end
    end
  end
end
