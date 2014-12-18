require 'fog/vcloud/models/compute/organization'

module Fog
  module Vcloud
    class Compute
      class Organizations < Collection
        model Fog::Vcloud::Compute::Organization

        undef_method :create

        def all
          raw_orgs = service.get_organizations
          data = raw_orgs.body[:Org]
          load(data)
        end

        def get(uri)
          service.get_organization(uri)
        rescue Fog::Errors::NotFound
          nil
        end
      end
    end
  end
end
