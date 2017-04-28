class CustomField < ActiveRecord::Base
  has_many :custom_field_properties, dependent: :restrict_with_error
  has_many :clients, through: :custom_field_properties, source: :custom_formable, source_type: 'Client'
  has_many :users, through: :custom_field_properties, source: :custom_formable, source_type: 'User'
  has_many :partners, through: :custom_field_properties, source: :custom_formable, source_type: 'Partner'
  has_many :families, through: :custom_field_properties, source: :custom_formable, source_type: 'Family'

  has_paper_trail

  validate  :enable_remove_fields, if: 'id.present?'
  validates :entity_type, :form_title, presence: true
  validates :form_title, uniqueness: { case_sensitive: false, scope: :entity_type }
  validates :time_of_frequency, presence: true,
                                numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: 'frequency.present?'
  validate :presence_of_fields, if: 'field_objs.empty?'
  validate :uniq_fields, if: 'fields.present?'

  before_save :set_time_of_frequency
  before_save :set_ngo_name, if: 'ngo_name.blank?'

  scope :by_form_title,  ->(value)  { where('form_title iLIKE ?', "%#{value}%") }
  scope :client_forms,   ->         { where(entity_type: 'Client') }
  scope :family_forms,   ->         { where(entity_type: 'Family') }
  scope :partner_forms,  ->         { where(entity_type: 'Partner') }
  scope :user_forms,     ->         { where(entity_type: 'User') }
  scope :not_used_forms, ->(value)  { where.not(id: value) }
  scope :order_by_form_title, ->    { order(:form_title) }


  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Family', 'Partner', 'User'].freeze

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
    errors.add(:fields, "can't be blank")
  end

  def uniq_fields
    labels = field_objs.collect do |object|
      object['label']
    end
    duplicate = labels.detect{ |e| labels.count(e) > 1 }
    errors.add(:fields, I18n.t('must_be_uniq')) if duplicate.present?
  end

  def field_objs
    fields.present? ? JSON.parse(fields) : fields
  end

  def enable_remove_fields
    entity_custom_fields_validate(self)
  end

  def entity_custom_fields_validate(custom_field)
    error_fields = []
    current_fields = []
    entity_custom_fields = []
    case custom_field.entity_type
    when 'Client'
      entity_custom_fields = custom_field.client_custom_fields
    when 'Family'
      entity_custom_fields = custom_field.family_custom_fields
    when 'Partner'
      entity_custom_fields = custom_field.partner_custom_fields
    when 'User'
      entity_custom_fields = custom_field.user_custom_fields
    end
    entity_custom_fields.each do |entity_custom_field|
      if entity_custom_field.properties.present?
        properties = JSON.parse(entity_custom_field.properties)
        current_fields = CustomField.find(custom_field).fields
        fields = custom_field.fields
        previous_fields = JSON.parse(current_fields) - JSON.parse(fields)
        next if previous_fields.blank?
        previous_fields.each do |field|
          label_name = properties[field['label']]
          next if label_name.blank?
          if field['type'] == 'checkbox-group' && label_name.first.present?
            error_fields << field['label']
          else
            error_fields << field['label']
          end
        end
      end
    end
    if error_fields.any?
      error_message       = "#{error_fields.uniq.join(', ')} #{I18n.t('cannot_remove')}"
      custom_field.fields = current_fields
      errors.add(:fields, "#{error_message} ")
    end
  end
end
