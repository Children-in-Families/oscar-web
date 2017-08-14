class ClientEnrollmentTracking < ActiveRecord::Base
  belongs_to :client_enrollment
  belongs_to :tracking

  has_many :form_builder_attachments, as: :form_buildable, dependent: :destroy

  accepts_nested_attributes_for :form_builder_attachments, reject_if: proc { |attributes| attributes['name'].blank? &&  attributes['file'].blank? }

  has_paper_trail

  scope :ordered, -> { order(:created_at) }
  scope :enrollment_trackings_by, -> (tracking) { where(tracking_id: tracking) }

  validate do |obj|
    CustomFormPresentValidator.new(obj, 'tracking', 'fields').validate
    CustomFormNumericalityValidator.new(obj, 'tracking', 'fields').validate
    CustomFormEmailValidator.new(obj, 'tracking', 'fields').validate
  end
end
