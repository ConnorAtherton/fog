module Fog
  module Vcloud
    class Compute
      class Real
        def delete_vapp
          request({
            path: "vApp/#{id}",
            method: "DELETE"
          })
        end
      end
    end
  end
end
