module Fog
  module Compute
    class Vcloud
      class Real
        def delete_vapp(id, force=true)
          request({
            path: "vApp/#{id}",
            expects: 200,
            method: 'DELETE',
            query: (force ? "?force=true" : nil)
          })
        end
      end
    end
  end
end
