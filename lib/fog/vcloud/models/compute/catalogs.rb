require 'fog/core/collection'
require 'fog/vcloud/models/compute/catalog'

module Fog
  module Compute
    class Vcloud
      class Catalogs < Collection
        model Fog::Compute::Vcloud::Catalog

        attribute :organization

        def all
          catalogs = organization.links.select { |link| link[:type] == "application/vnd.vmware.vcloud.catalog+xml" }
          catalogs = catalogs.map {|c| service.add_id_from_href!(c) }
          binding.pry
          load(catalogs)
        end

        def get_by_id(id)
          service.get_catalog(id)
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
