class ServiceDelivery < ActiveRecord::Base
  has_many :service_delivery_tasks, dependent: :restrict_with_error
  has_many :tasks, through:   :service_delivery_tasks
  validates :name, presence: true
end
