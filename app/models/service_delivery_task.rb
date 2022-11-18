class ServiceDeliveryTask < ApplicationRecord
  belongs_to :task
  belongs_to :service_delivery
end
