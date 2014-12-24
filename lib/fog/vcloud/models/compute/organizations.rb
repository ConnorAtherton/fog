require 'fog/core/collection'
require 'fog/vcloud/models/compute/organization'

module Fog
  module Compute
    class Vcloud
      class Organizations < Collection
        model Fog::Compute::Vcloud::Organization

        def all
          orgs = service.get_organizations
          orgs = orgs.body[:Org]
          orgs
        end

        def get_by_id(id)
          org = service.get_organization(id).data[:body]
          service.add_id_from_href!(org)
          org
        end
      end
    end
  end
end
