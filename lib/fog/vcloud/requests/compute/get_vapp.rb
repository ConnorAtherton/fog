module Fog
  module Compute
    class Vcloud
      class Real
        def get_vapp(id)
          request({
            path: "vApp/#{id}"
          })
        end
      end
    end
  end
end
