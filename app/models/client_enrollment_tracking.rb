class ClientEnrollmentTracking < ActiveRecord::Base
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern
  include ClearanceCustomFormConcern

  belongs_to :client_enrollment
  belongs_to :tracking

  has_paper_trail

  scope :ordered, -> { order(:created_at) }
  scope :enrollment_trackings_by, -> (tracking) { where(tracking_id: tracking) }

  delegate :program_stream, to: :client_enrollment
  delegate :name, to: :program_stream, prefix: true

  after_save :create_client_enrollment_tracking_history
  after_commit :flush_cache

  # validate do |obj|
  #   CustomFormPresentValidator.new(obj, 'tracking', 'fields').validate
  #   CustomFormNumericalityValidator.new(obj, 'tracking', 'fields').validate
  #   CustomFormEmailValidator.new(obj, 'tracking', 'fields').validate
  # end

  def self.properties_by(value, object = nil)
    value = value.gsub(/\'+/, "''")
    field_properties = select("client_enrollment_trackings.id, client_enrollment_trackings.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def self.cached_tracking_order_created_at(object, fields_third, ids)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'ClientEnrollmentTracking', 'cached_tracking_order_created_at', *fields_third, *ids.sort]) {
      joins(:tracking).where(trackings: { name: fields_third }, client_enrollment_trackings: { client_enrollment_id: ids }).order(created_at: :desc).first.try(:properties)
    }
  end

  def self.cached_client_enrollment_tracking(object, fields_third, ids)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'ClientEnrollmentTracking', 'cached_client_enrollment_tracking', *fields_third, *ids.sort]) {
      joins(:tracking).where(trackings: { name: fields_third }, client_enrollment_trackings: { client_enrollment_id: ids }).distinct
    }
  end

  def is_tracking_editable_limited?
    return true if !Organization.ratanak?

    setting = Setting.first
    return true if setting.try(:tracking_form_edit_limit).zero?
    tracking_form_edit_limit = setting.try(:tracking_form_edit_limit).zero? ? 2 : setting.try(:tracking_form_edit_limit)
    edit_frequency = setting.try(:tracking_form_edit_frequency)
    created_at >= tracking_form_edit_limit.send(edit_frequency).ago
  end

  private

  def create_client_enrollment_tracking_history
    ClientEnrollmentTrackingHistory.initial(self)
  end

  def flush_cache
    cached_tracking_order_created_at_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_tracking_order_created_at/].blank? }
    cached_tracking_order_created_at_keys.each { |key| Rails.cache.delete(key) }
    cached_client_enrollment_tracking_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_enrollment_tracking/].blank? }
    cached_client_enrollment_tracking_keys.each { |key| Rails.cache.delete(key) }
  end
end
