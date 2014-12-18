module Fog
  module Vcloud
    class Compute
      class Real
        def get_organizations
          headers = {
            'Accept' => "#{default_header_params}com.vmware.vchs.sc.restapi.model.organizationlisttype"
          }

         request({
            :headers  => headers,
            :path     => "sc/organizations"
          })
        end
      end
    end
  end
end
