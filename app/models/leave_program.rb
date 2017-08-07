class LeaveProgram < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :program_stream
  has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy

  validates :exit_date, presence: true

  accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? &&  attributes['file'].blank? }

  after_create :set_client_status

  has_paper_trail

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'exit_program').validate
  end

  def set_client_status
    self.client_enrollment.update_columns(status: 'Exited')

    client = Client.find(self.client_enrollment.client_id)
    if client.cases.current.nil? && client.client_enrollments.active.empty?
      client.update_attributes(status: 'Referred')
    end
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end
end
