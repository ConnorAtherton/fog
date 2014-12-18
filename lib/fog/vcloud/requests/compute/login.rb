module Fog
  module Vcloud
    class Compute
      class Real
        def login
          headers = {
            'Accept' => default_header_params,
            'Authorization' => authorization_header
          }
          puts "requesting auth token..."

          unauthenticated_request({
            :expects  => 201,
            :headers  => headers,
            :method   => 'POST',
            :parse    => true,
            :path     => "iam/login"
          })
        end
      end
    end
  end
end
