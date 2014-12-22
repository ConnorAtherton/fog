require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Organization < Model
        identity :href, :aliases => :Href
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :id
        attribute :name
        attribute :description, :aliases => :Description
        attribute :links, :aliases => :Link, :type => :array
        attribute :type
        attribute :full_name, :aliases => :FullName

        def networks
          requires :id
          service.networks(:organization => self)
        end

        def tasks
          requires :id
          service.tasks(:organization => self)
        end

        def vdcs
          requires :id
          service.vdcs(:organization => self)
        end

        def catalogs
          requires :id
          service.catalogs(:organization => self)
        end
      end
    end
  end
end
