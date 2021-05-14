class ServiceDeliveryTask < ActiveRecord::Base
  belongs_to :task
  belongs_to :service_delivery
end
