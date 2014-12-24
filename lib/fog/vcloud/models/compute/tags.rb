require 'fog/core/collection'
require 'fog/vcloud/models/compute/tag'

module Fog
  module Compute
    class Vcloud
      class Tags < Collection
        model Fog::Compute::Vcloud::Tag

        attribute :href, :aliases => :Href

        def item_list
          metadata = service.get_metadata(self.href)
          load(metadata.body[:MetadataEntry]) if metadata.body[:MetadataEntry]
        end

        def get(uri)
          service.get_metadata(uri)
        rescue Fog::Errors::NotFound
          nil
        end

        def create(opts)
          service.configure_metadata(opts.merge(href: href))
        end
      end
    end
  end
end
