class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :trackings, dependent: :destroy
  has_one :leave_program, dependent: :destroy

  scope :enrollments_by, ->(client) { where(client_id: client).order(:created_at) }
  scope :active, -> { where(status: 'Active') }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'enrollment').validate
  end
end
