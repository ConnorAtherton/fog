module Fog
  module Compute
    class Vcloud
      class Real
        def get_catalog(id)
          request({
            path: "catalog/#{id}"
          })
        end
      end
    end
  end
end
