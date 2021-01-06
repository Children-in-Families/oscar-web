class EnrollmentTracking < ActiveRecord::Base
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern

  belongs_to :enrollment
  belongs_to :tracking

  has_paper_trail

  scope :ordered, -> { order(:created_at) }
  scope :enrollment_trackings_by, -> (tracking) { where(tracking_id: tracking) }

  # may be used later in family book
  # delegate :program_stream, to: :enrollment
  # delegate :name, to: :program_stream, prefix: true

  after_save :create_entity_enrollment_tracking_history

  # may be used later in family grid
  # def self.properties_by(value, object=nil)
  #   value = value.gsub(/\'+/, "''")
  #   field_properties = select("client_enrollment_trackings.id, client_enrollment_trackings.properties ->  '#{value}' as field_properties").collect(&:field_properties)
  #   field_properties.select(&:present?)
  # end

  def get_form_builder_attachment(value)
    form_builder_attachments.find_by(name: value)
  end

  private

  def create_entity_enrollment_tracking_history
    EntityEnrollmentTrackingHistory.initial(self)
  end
end
