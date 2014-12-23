module Fog
  module Compute
    class Vcloud
      class Real
        def get_catalog_item(id)
          request({
            path: "catalogItem/#{id}"
          })
        end
      end
    end
  end
end
