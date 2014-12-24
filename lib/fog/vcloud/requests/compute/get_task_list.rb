module Fog
  module Compute
    class Vcloud
      class Real
        def get_task_list(id)
          request({
            path: "tasksList/#{id}"
          })
        end
      end
    end
  end
end
