require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Catalog < Model
        identity :href, :aliases => :Href
        attribute :links, :aliases => :Links, :type => :array
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :id
        attribute :type
        attribute :name

        def catalog_items
          requires :id
          service.get_catalog_items(:catalog => self)
        end
      end
    end
  end
end
