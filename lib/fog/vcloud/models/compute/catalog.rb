require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Catalog < Model
        identity :href, :aliases => :Href
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :id
        attribute :type
        attribute :name
        attribute :description, :aliases => :Description
        attribute :is_published, :aliases => :IsPublished, :type => :boolean

        def catalog_items
          requires :id
          service.catalog_items(:cat => self)
        end
      end
    end
  end
end
