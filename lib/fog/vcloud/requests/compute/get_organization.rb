module Fog
  module Compute
    class Vcloud
      class Real
        def get_organization(id)
          request({
            :path => "org/#{id}"
          })
        end
      end
    end
  end
end
