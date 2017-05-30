class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :trackings, dependent: :destroy
  has_one :leave_program, dependent: :destroy

  scope :enrollments_by, ->(client, program_stream) { where(client_id: client, program_stream_id: program_stream) }
  scope :active, -> { where(status: 'Active') }
end
