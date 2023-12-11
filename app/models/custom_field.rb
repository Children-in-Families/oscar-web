class CustomField < ActiveRecord::Base
  include UpdateFieldLabelsFormBuilder

  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Community', 'Family', 'Partner', 'User'].freeze

  has_many :custom_field_properties, dependent: :restrict_with_error
  has_many :clients, through: :custom_field_properties, source: :custom_formable, source_type: 'Client'
  has_many :users, through: :custom_field_properties, source: :custom_formable, source_type: 'User'
  has_many :partners, through: :custom_field_properties, source: :custom_formable, source_type: 'Partner'
  has_many :families, through: :custom_field_properties, source: :custom_formable, source_type: 'Family'
  has_many :communities, through: :custom_field_properties, source: :custom_formable, source_type: 'Community'
  has_many :custom_field_permissions, dependent: :destroy
  has_many :user_permissions, through: :custom_field_permissions

  has_paper_trail

  validates :entity_type, inclusion: { in: ENTITY_TYPES }
  validates :entity_type, :form_title, presence: true
  validates :form_title, uniqueness: { case_sensitive: false, scope: :entity_type }
  validates :time_of_frequency, presence: true,
                                numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { frequency.present? }
  validates :fields, presence: true
  validate  :uniq_fields, :field_label, if: -> { fields.present? }

  before_save :set_time_of_frequency
  after_create :build_permission
  before_save :set_ngo_name, if: -> { ngo_name.blank? }
  after_update :update_custom_field_label, :update_save_search, if: -> { fields_changed? }
  after_commit :flush_cache

  scope :by_form_title,  ->(value)  { where('form_title iLIKE ?', "%#{value.squish}%") }
  scope :client_forms,   ->         { where(entity_type: 'Client') }
  scope :family_forms,   ->         { where(entity_type: 'Family') }
  scope :community_forms, ->        { where(entity_type: 'Community') }
  scope :partner_forms,  ->         { where(entity_type: 'Partner') }
  scope :user_forms,     ->         { where(entity_type: 'User') }
  scope :not_used_forms, ->(value)  { where.not(id: value) }
  scope :ordered_by,     ->(column) { order(column) }
  scope :order_by_form_title, ->    { order(:form_title) }
  scope :visible, -> { where(hidden: false) }

  def self.client_used_form
    ids = CustomFieldProperty.where(custom_formable_type: 'Client').pluck(:custom_field_id).uniq
    where(id: ids)
  end

  def set_time_of_frequency
    if frequency.present?
      self.time_of_frequency = time_of_frequency
    else
      self.time_of_frequency = 0
    end
  end

  def set_ngo_name
    self.ngo_name = Organization.current.full_name
  end

  def presence_of_fields
    errors.add(:fields, I18n.t('cannot_be_blank'))
  end

  def uniq_fields
    labels = fields.map{ |f| f['label'] }
    labels.delete('Separation Line')
    duplicate = labels.detect { |e| labels.count(e) > 1 }
    errors.add(:fields, I18n.t('must_be_uniq')) if duplicate.present?
  end

  def field_label
    fields.each do |object|
      if object['label'].blank?
        errors.add(:fields, I18n.t('field_label_cannot_be_blank'))
        break
      end
    end
  end

  def build_permission
    User.without_deleted_users.non_strategic_overviewers.each do |user|
      self.custom_field_permissions.find_or_create_by(user_id: user.id)
    end
  end

  def self.cache_object(id)
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomField', id]) { find(id) }
  end

  def self.cached_order_by_form_title(form_ids = [])
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomField', 'cached_order_by_form_title', *form_ids.sort]) {
      where(id: form_ids).order_by_form_title.to_a
    }
  end

  def self.cached_custom_form_ids(custom_form_ids)
    if custom_form_ids.is_a?(Array)
      Rails.cache.fetch([Apartment::Tenant.current, 'CustomField', 'cached_custom_form_ids', *custom_form_ids.sort]) {
        where(id: custom_form_ids).to_a
      }
    else
      Rails.cache.fetch([Apartment::Tenant.current, 'CustomField', 'cached_custom_form_ids', custom_form_ids]) {
        where(id: custom_form_ids).to_a
      }
    end
  end

  def self.cached_custom_form_ids_attach_with(custom_form_ids, attach_with)
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomField', 'cached_custom_form_ids_attach_with', custom_form_ids, attach_with]) {
      where(id: custom_form_ids, entity_type: attach_with).to_a
    }
  end

  def self.cached_client_custom_field_find_by(object, fields_second)
    Rails.cache.fetch([Apartment::Tenant.current, 'Client', object.id, 'cached_client_custom_field_find_by', fields_second]) do
      find_by(form_title: fields_second)&.id
    end
  end

  private

  def update_custom_field_label
    custom_field_properties.ids.each_slice(1000).each do |chuck_object_ids|
      CustomFieldPropertyUpdateWorker.perform_async(Apartment::Tenant.current, fields_change.last, fields_was, chuck_object_ids)
    end
  end

  def update_save_search
    saved_searches = AdvancedSearch.all
    saved_searches.each do |ss|
      queries       = ss.queries
      updated_query = get_rules(queries, ss)
    end
  end

  def get_rules(queries, ss)
    custom_form_ids = CustomField.ids
    if ss.custom_forms.present?
      if !(custom_form_ids & class_eval(ss.custom_forms)).empty?
        class_eval(ss.custom_forms).each do |custom_form_id|
          next unless custom_form_ids.include?(custom_form_id)
          custom_form = CustomField.find(custom_form_id)
          custom_form.fields.each do |field|
            updated_field = field["label"]
            queries["rules"].each do |rule|
              custom_field_old_queries = get_rules(rule, ss) if rule.has_key?('rules')
              if rule["id"].present?
                old_field  = rule["id"].gsub(/.*__/i,'')
                if updated_field[/#{old_field[0..5]}.*/i]
                  custom_field_value = rule["id"].slice(/.*__/i)
                  query_rule = "#{custom_field_value}#{updated_field}"
                  rule["id"] = query_rule
                  ss.save
                end
              end
            end
          end
        end
      end
    end
  end

  def flush_cache
    Rails.cache.delete([Apartment::Tenant.current, 'CustomField', self.id])
    cached_order_by_form_title_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_order_by_form_title/].blank? }
    cached_order_by_form_title_keys.each { |key| Rails.cache.delete(key) }
    cached_custom_form_ids_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_custom_form_ids/].blank? }
    cached_custom_form_ids_keys.each { |key| Rails.cache.delete(key) }
    cached_custom_form_ids_attach_with_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_custom_form_ids_attach_with/].blank? }
    cached_custom_form_ids_attach_with_keys.each { |key| Rails.cache.delete(key) }
    cached_client_custom_field_find_by_keys = Rails.cache.instance_variable_get(:@data).keys.reject { |key| key[/cached_client_custom_field_find_by/].blank? }
    cached_client_custom_field_find_by_keys.each { |key| Rails.cache.delete(key) }
  end
end
