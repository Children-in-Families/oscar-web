class LeaveProgram < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :program_stream
  has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy

  validates :exit_date, presence: true
  validate :exit_date_value, if: 'exit_date.present?'

  accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? &&  attributes['file'].blank? }

  after_save :create_leave_program_history
  after_create :update_enrollment_status, :set_client_status

  has_paper_trail

  scope :find_by_program_stream_id, -> (value) { where(program_stream_id: value) }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'exit_program').validate
  end

  def self.properties_by(value)
    value = value.gsub("'", "''")
    field_properties = select("leave_programs.id, leave_programs.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def update_enrollment_status
    self.client_enrollment.update_columns(status: 'Exited')
  end

  def set_client_status
    client = Client.find(self.client_enrollment.client_id)
    if client.client_enrollments.active.empty?
      client.status = 'Accepted'
      client.save(validate: false)
    end
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  private

  def create_leave_program_history
      LeaveProgramHistory.initial(self)
  end

  def exit_date_value
    if exit_date < client_enrollment.enrollment_date
      errors.add(:exit_date, I18n.t('invalid_program_exit_date'))
    end
  end
end
