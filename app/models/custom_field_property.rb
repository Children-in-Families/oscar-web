class CustomFieldProperty < ActiveRecord::Base
  include NestedAttributesConcern
  include ClientEnrollmentTrackingConcern
  include ClearanceCustomFormConcern

  mount_uploaders :attachments, CustomFieldPropertyUploader

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field
  belongs_to :user
  belongs_to :client, class_name: 'Client', foreign_key: 'custom_formable_id'
  belongs_to :family, class_name: 'Family', foreign_key: 'custom_formable_id'
  belongs_to :user, class_name: 'User', foreign_key: 'custom_formable_id'
  belongs_to :partner, class_name: 'Partner', foreign_key: 'custom_formable_id'
  belongs_to :community, class_name: 'Community', foreign_key: 'custom_formable_id'

  scope :by_custom_field, -> (value) { where(custom_field: value) }
  scope :most_recents, -> { order(created_at: :desc) }

  has_paper_trail

  after_save :create_client_history, if: :client_form?

  validates :custom_field_id, presence: true

  after_commit :flush_cache

  def client_form?
    custom_formable_type == 'Client'
  end

  def self.properties_by(value)
    value = value.gsub(/\'+/, "''")
    field_properties = select("custom_field_properties.id, custom_field_properties.properties ->  '#{value}' as field_properties").collect(&:field_properties)
    field_properties.select(&:present?)
  end

  def is_editable?
    setting = Setting.first
    return true if setting.try(:custom_field_limit).zero?

    max_duration = setting.try(:custom_field_limit).zero? ? 2 : setting.try(:custom_field_limit)
    custom_field_frequency = setting.try(:custom_field_frequency)
    created_at >= max_duration.send(custom_field_frequency).ago
  end

  def self.cached_custom_formable_type
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomFieldProperty', 'cached_custom_formable_type']) {
      where(custom_formable_type: 'Client').pluck(:custom_field_id).uniq
    }
  end

  def self.cached_client_custom_field_properties_count(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'CustomFieldProperty', 'cached_client_custom_field_properties_count', *fields_second]) {
      joins(:custom_field).where(custom_fields: { form_title: fields_second, entity_type: 'Client' }).count
    }
  end

  def self.cached_client_custom_field_properties_order(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'cached_client_custom_field_properties_order', *fields_second]) do
      joins(:custom_field).where(custom_fields: { form_title: fields_second, entity_type: 'Client' }).order(created_at: :desc).first.try(:properties)
    end
  end

  def self.cached_client_custom_field_properties_properties_by(object, custom_field_id, sql, format_field_value)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'cached_client_custom_field_properties_properties_by', custom_field_id, format_field_value.downcase.parameterize.underscore]) do
      where(custom_field_id: custom_field_id).where(sql).properties_by(format_field_value)
    end
  end

  private

  def create_client_history
    # ClientHistory.initial(custom_formable)
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'CustomFieldProperty', 'cached_custom_formable_type'])
    cached_client_custom_field_properties_count_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_count/].blank? }
    cached_client_custom_field_properties_count_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_properties_order_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_order/].blank? }
    cached_client_custom_field_properties_order_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_properties_properties_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_properties_properties_by/].blank? }
    cached_client_custom_field_properties_properties_by_keys.each { |key| Rails.cache.delete(key) }
  end
end
