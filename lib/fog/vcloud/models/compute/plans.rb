require 'fog/vcloud/models/compute/plan'

module Fog
  module Vcloud
    class Compute
      class Plans < Fog::Vcloud::Collection
        model Fog::Vcloud::Compute::Plan

        attribute :href, :aliases => :Href

        def all
          service.get_plans.data[:body]
        end

        def get(uri)
          service.get_metadata(uri)
        rescue Fog::Errors::NotFound
          nil
        end
      end
    end
  end
end
