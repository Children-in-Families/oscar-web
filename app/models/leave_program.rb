class LeaveProgram < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :program_stream

  validates :exit_date, presence: true

  after_create :set_client_status

  has_paper_trail

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'exit_program').validate
  end

  def set_client_status
    self.client_enrollment.update_columns(status: 'Exited')

    client = Client.find self.client_enrollment.client_id

    if client.cases.exclude_referred.current.present?
      case_status = client.cases.exclude_referred.current.case_type
      client_status = "Active #{case_status}" if ProgramStream.active_enrollments(client).count == 0
    else
      client_status = "Referred"
    end
    client.update_attributes(status: client_status) if client_status.present?
  end
end
