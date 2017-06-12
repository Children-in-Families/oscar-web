class ClientEnrollmentTracking < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :tracking

  scope :ordered, -> { order(:created_at) }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'tracking', 'fields').validate
    CustomFormNumericalityValidator.new(obj, 'tracking', 'fields').validate
    CustomFormEmailValidator.new(obj, 'tracking', 'fields').validate
  end
end
