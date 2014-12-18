module Fog
  module Vcloud
    class Compute
      class Real
        def get_plans
          headers = {
            'Accept' => "#{default_header_params}class=com.vmware.vchs.sc.restapi.model.planlisttype"
          }

         request({
            :expects  => 200,
            :headers  => headers,
            :method   => 'GET',
            :parse    => true,
            :path     => "sc/plans"
          })
        end
      end
    end
  end
end
