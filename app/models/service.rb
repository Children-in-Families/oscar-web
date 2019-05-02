class Service < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :parent,           class_name: 'Service', optional: true

  has_many :children,           class_name: 'Service',
                                foreign_key: 'parent_id',
                                dependent: :destroy

  has_many   :program_stream_services, dependent: :destroy
  has_many   :program_streams, through: :program_stream_services
end
