class ClientEnrollment < ActiveRecord::Base
  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :form_builder_attachments, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  validates :enrollment_date, presence: true
  # accepts_nested_attributes_for :form_builder_attachments

  has_paper_trail

  scope :enrollments_by, ->(client) { where(client_id: client).order(:created_at) }
  scope :active, -> { where(status: 'Active') }
  scope :inactive, -> { where(status: 'Exited') }

  after_create :set_client_status

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
    client_status = 'Active' if ProgramStream.active_enrollments(client).count > 0
    client.update_attributes(status: client_status) if client.status != 'Active' && client_status.present?
  end
end
