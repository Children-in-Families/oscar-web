class Service < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :parent,           class_name: 'Service'
  has_many :children,           class_name: 'Service', foreign_key: 'parent_id', dependent: :destroy

  has_many   :program_stream_services, dependent: :destroy
  has_many   :program_streams, through: :program_stream_services

  validates :name, presence: true

  default_scope { with_deleted }
  scope :only_parents,  -> { where(parent_id: nil) }
  scope :only_children, -> { where.not(parent_id: nil) }
  scope :names,         -> { only_children.pluck(:name) }
end
