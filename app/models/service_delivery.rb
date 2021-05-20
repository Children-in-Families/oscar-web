class ServiceDelivery < ActiveRecord::Base
  belongs_to :parent,           class_name: 'ServiceDelivery'
  has_many :children,           class_name: 'ServiceDelivery', foreign_key: 'parent_id', dependent: :destroy
  has_many :service_delivery_tasks, dependent: :restrict_with_error
  has_many :tasks, through:   :service_delivery_tasks
  validates :name, :parent_id, presence: true

  scope :only_parents,  -> { where(parent_id: nil) }
  scope :only_children, -> { where.not(parent_id: nil) }
  scope :names,         -> { only_children.pluck(:name) }
end
