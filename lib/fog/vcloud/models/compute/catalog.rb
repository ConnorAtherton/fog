require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Catalog < Model
        identity :href, :aliases => :Href
        attribute :links, :aliases => :Link, :type => :array
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :type
        attribute :name

        def catalog_items
          @catalog_items ||= Fog::Vcloud::Compute::CatalogItems.
            new( :service => service,
                 :href => href )
        end
      end
    end
  end
end
