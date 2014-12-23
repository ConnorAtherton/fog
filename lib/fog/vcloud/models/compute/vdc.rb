require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Vdc < Model
        identity :href, :aliases => :Href
        attribute :links, :aliases => :Link, :type => :array
        ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

        attribute :name
        attribute :id
        attribute :type
        attribute :description, :aliases => :Description
        attribute :network_quota, :aliases => :NetworkQuota, :type => :integer
        attribute :nic_quota, :aliases => :NicQuota, :type => :integer
        attribute :vm_quota, :aliases => :VmQuota, :type => :integer
        attribute :is_enabled, :aliases => :IsEnabled, :type => :boolean
        attribute :compute_capacity, :aliases => :ComputeCapacity
        attribute :storage_capacity, :aliases => :StorageCapacity
        attribute :available_networks, :aliases => :AvailableNetworks, :squash => :Network
        attribute :resource_entities, :aliases => :ResourceEntities, :squash => :ResourceEntity

        def networks
          requires :id
          service.networks(:vdc => self)
        end

        def vapps
          requires :id
          service.vapps(:vdc => self)
        end
      end
    end
  end
end
