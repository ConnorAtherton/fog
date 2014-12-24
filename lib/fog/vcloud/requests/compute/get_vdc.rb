module Fog
  module Compute
    class Vcloud
      class Real
        def get_vdc(id)
          request(
            path: "vdc/#{id}"
          )
        end
      end
    end
  end
end
