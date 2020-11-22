class Enrollment < ActiveRecord::Base
  include NestedAttributesConcern

  acts_as_paranoid without_default_scope: true

  belongs_to :programmable, polymorphic: true
  belongs_to :program_stream

  has_one :leave_program, dependent: :destroy

  alias_attribute :new_date, :enrollment_date

  scope :active, -> { where(status: 'Active') }
  scope :enrollments_by, -> (obj) { where(programmable_id: obj.id) }
end
