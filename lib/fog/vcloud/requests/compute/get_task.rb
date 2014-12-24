module Fog
  module Compute
    class Vcloud
      class Real
        def get_task(id)
          request({
            path: "task/#{id}"
          })
        end
      end
    end
  end
end
