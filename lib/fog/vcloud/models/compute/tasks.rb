require 'fog/core/collection'
require 'fog/vcloud/models/compute/task'

module Fog
  module Compute
    class Vcloud
      class Tasks < Collection
        model Fog::Compute::Vcloud::Task

        attribute :href, :aliases => :Href
        attribute :organization

        def item_list
          data = service.get_task_list(organization.id).body
          data = data[:Task].each {|task| service.add_id_from_href!(task)}
        end

        def get_by_id(id)
          data = service.get_task(id).body
          return nil unless data
          service.add_id_from_href!(data)
          data[:progress] ||= 0
          data
        end
      end
    end
  end
end
