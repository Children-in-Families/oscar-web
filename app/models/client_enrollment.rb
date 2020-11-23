class ClientEnrollment < ActiveRecord::Base
  include ClientRetouch
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  acts_as_paranoid without_default_scope: true

  belongs_to :client
  belongs_to :program_stream

  has_many :client_enrollment_trackings, dependent: :destroy
  has_many :trackings, through: :client_enrollment_trackings
  has_one :leave_program, dependent: :destroy

  alias_attribute :new_date, :enrollment_date

  validates :enrollment_date, presence: true
  validate :enrollment_date_value, if: 'enrollment_date.present?'

  has_paper_trail

  scope :enrollments_by,              ->(client)         { where(client_id: client) }
  scope :find_by_program_stream_id,   ->(value)          { where(program_stream_id: value) }
  scope :active,                      ->                 { where(status: 'Active') }
  scope :inactive,                    ->                 { where(status: 'Exited') }

  delegate :name, to: :program_stream, prefix: true, allow_nil: true

  after_create :set_client_status
  after_save :create_client_enrollment_history
  after_destroy :reset_client_status

  def active?
    status == 'Active'
  end

  def has_client_enrollment_tracking?
    client_enrollment_trackings.present?
  end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("client_enrollments.id, client_enrollments.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def set_client_status
    client = Client.find self.client_id
    client_status = 'Active'

    if client_status.present?
      client.status = client_status
      client.save(validate: false)
    end
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  def reset_client_status
    client = Client.find(client_id)
    return if client.client_enrollments.active.any?
    client.status = 'Accepted'
    client.save(validate: false)
  end

  def short_enrollment_date
    enrollment_date.end_of_month.strftime '%b-%y'
  end

  private

  def create_client_enrollment_history
    ClientEnrollmentHistory.initial(self)
  end

  def enrollment_date_value
    if leave_program.present? && leave_program.exit_date < enrollment_date
      errors.add(:enrollment_date, I18n.t('invalid_program_enrollment_date'))
    end
  end
end
