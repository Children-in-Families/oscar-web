class Enrollment < ActiveRecord::Base
  belongs_to :programmable, polymorphic: true
  belongs_to :program_stream

  scope :active, -> { where(status: 'Active') }
  scope :enrollments_by, -> (obj) { where(programmable_id: obj.id) }
end
