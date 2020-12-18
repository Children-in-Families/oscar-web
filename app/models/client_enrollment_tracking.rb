class ClientEnrollmentTracking < ApplicationRecord
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  belongs_to :client_enrollment
  belongs_to :tracking

  has_paper_trail

  scope :ordered, -> { order(:created_at) }
  scope :enrollment_trackings_by, -> (tracking) { where(tracking_id: tracking) }

  delegate :program_stream, to: :client_enrollment
  delegate :name, to: :program_stream, prefix: true

  after_save :create_client_enrollment_tracking_history

  # validate do |obj|
  #   CustomFormPresentValidator.new(obj, 'tracking', 'fields').validate
  #   CustomFormNumericalityValidator.new(obj, 'tracking', 'fields').validate
  #   CustomFormEmailValidator.new(obj, 'tracking', 'fields').validate
  # end

  def self.properties_by(value, object=nil)
    value = value.gsub(/\'+/, "''")
    field_properties = select("client_enrollment_trackings.id, client_enrollment_trackings.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  private

  def create_client_enrollment_tracking_history
    ClientEnrollmentTrackingHistory.initial(self)
  end
end
