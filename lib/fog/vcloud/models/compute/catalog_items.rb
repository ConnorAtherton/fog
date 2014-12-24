require 'fog/core/collection'
require 'fog/vcloud/models/compute/catalog_item'

module Fog
  module Compute
    class Vcloud
      class CatalogItems < Collection
        model Fog::Compute::Vcloud::CatalogItem

        attribute :cat

        def item_list
          catalog = service.get_catalog(cat.id)
          items = catalog.body[:CatalogItems]
          items[:CatalogItem]
        end

        def get_by_id(id)
          data = service.get_catalog_item(id)
          data.body
        end
      end
    end
  end
end
