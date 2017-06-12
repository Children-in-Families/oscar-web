class ClientEnrollmentTracking < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :tracking

  scope :ordered, -> { order(:created_at) }
  scope :enrollment_trackings_by, -> (tracking) { where(tracking_id: tracking) }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'tracking', 'fields').validate
    CustomFormNumericalityValidator.new(obj, 'tracking', 'fields').validate
    CustomFormEmailValidator.new(obj, 'tracking', 'fields').validate
  end
end
