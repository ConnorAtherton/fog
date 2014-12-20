module Fog
  module Compute
    class Vcloud
      class Real
        def login
          headers = {
            'Accept' => default_header_params,
            'Authorization' => authorization_header,
            'Content-Type'  => default_header_params
          }

          unauthenticated_request({
            :headers  => headers,
            :method   => 'POST',
            :path     => 'sessions' # @login_path
          })
        end
      end
    end
  end
end
