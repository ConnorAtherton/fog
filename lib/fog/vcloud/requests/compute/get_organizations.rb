module Fog
  module Compute
    class Vcloud
      class Real
        def get_organizations
          request({
            :path => "org"
          })
        end
      end
    end
  end
end
