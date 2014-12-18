module Fog
  module Vcloud
    class Compute
      class Plan < Fog::Vcloud::Model
        identity :href, :aliases => :Href
        attribute :links, :aliases => :Link, :type => :array

        attribute :key, :aliases => :Key
        attribute :value, :aliases => :Value

        def destroy
          service.delete_metadata(href)
        end
      end
    end
  end
end
