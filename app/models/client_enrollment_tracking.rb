class ClientEnrollmentTracking < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :tracking

  scope :ordered, -> { order(:created_at) }

  # validate do |obj|
  #   CustomFormPresentValidator.new(obj, 'program_stream', 'tracking').validate
  #   CustomFormNumericalityValidator.new(obj, 'program_stream', 'tracking').validate
  #   CustomFormEmailValidator.new(obj, 'program_stream', 'tracking').validate
  # end

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'tracking').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'tracking').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'tracking').validate
  end
end
