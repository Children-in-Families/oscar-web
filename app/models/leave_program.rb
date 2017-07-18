class LeaveProgram < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :program_stream

  validates :exit_date, presence: true

  has_paper_trail

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'exit_program').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'exit_program').validate
  end
end
