require 'fog/core/model'

module Fog
  module Compute
    class Vcloud
      class Task < Model
        identity  :id
        attribute :status
        attribute :type
        attribute :result, :aliases => :Result
        attribute :owner, :aliases => :Owner
        attribute :start_time, :aliases => :startTime #, :type => :time
        attribute :end_time, :aliases => :endTime #, :type => :time
        attribute :expiry_time, :aliases => :expiryTime #, :type => :time
        attribute :href
        attribute :name
        attribute :operation
        attribute :operation_name, :aliases => :operationName
        attribute :description, :aliases => :Description
        attribute :error, :aliases => :Error
        attribute :progress, :aliases => :Progress, :type => :integer
        attribute :cancel_requested, :aliases => :cancelRequested, :type => :boolean
        attribute :service_namespace, :aliases => :serviceNamespace
        attribute :details, :aliases => :Details

        def ready?
          status == 'success'
        end

        def success?
          status == 'success'
        end

        def non_running?
          status != 'running'
        end

        def cancel
          service.post_cancel_task(id)
        end
      end
    end
  end
end
