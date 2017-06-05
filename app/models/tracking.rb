class Tracking < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :program_stream

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'program_stream', 'tracking').validate
    CustomFormNumericalityValidator.new(obj, 'program_stream', 'tracking').validate
    CustomFormEmailValidator.new(obj, 'program_stream', 'tracking').validate
  end
end
