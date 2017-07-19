class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  validates :enrollment_date, presence: true

  has_paper_trail

  scope :enrollments_by, ->(client) { where(client_id: client).order(:created_at) }
  scope :active, -> { where(status: 'Active') }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'enrollment').validate
  end

  def has_client_enrollment_tracking?
    client_enrollment_trackings.present?
  end
end
