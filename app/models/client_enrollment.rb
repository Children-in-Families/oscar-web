class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  validates :enrollment_date, presence: true

  has_paper_trail

  scope :enrollments_by, ->(client) { where(client_id: client).order(created_at: :DESC) }
  scope :active, -> { where(status: 'Active') }
  scope :inactive, -> { where(status: 'Exited') }

  after_create :set_client_status
  after_destroy :reset_client_status

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'enrollment').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'enrollment').validate
  end

  def has_client_enrollment_tracking?
    client_enrollment_trackings.present?
  end

  def set_client_status
    client = Client.find self.client_id
    client_status = 'Active' unless client.cases.exclude_referred.currents.present?
    client.update_attributes(status: client_status) if client_status.present?
  end

  def reset_client_status
    client = Client.find(client_id)
    return if client.active_case? || client.client_enrollments.active.any?

    client.update(status: 'Referred')
  end
end
