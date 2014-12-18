module Fog
  module Vcloud
    class Compute
      class Real
        def get_instances
          headers = {
            'Accept' => default_header_params
          }

         request({
            :headers  => headers,
            :path     => "sc/instances"
          })
        end
      end
    end
  end
end
