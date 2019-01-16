class CustomField < ActiveRecord::Base
  include UpdateFieldLabelsFormBuilder

  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Family', 'Partner', 'User'].freeze

  has_many :custom_field_properties, dependent: :restrict_with_error
  has_many :clients, through: :custom_field_properties, source: :custom_formable, source_type: 'Client'
  has_many :users, through: :custom_field_properties, source: :custom_formable, source_type: 'User'
  has_many :partners, through: :custom_field_properties, source: :custom_formable, source_type: 'Partner'
  has_many :families, through: :custom_field_properties, source: :custom_formable, source_type: 'Family'
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
  after_update :update_custom_field_label, if: -> { fields_changed? }

  scope :by_form_title,  ->(value)  { where('form_title iLIKE ?', "%#{value.squish}%") }
  scope :client_forms,   ->         { where(entity_type: 'Client') }
  scope :family_forms,   ->         { where(entity_type: 'Family') }
  scope :partner_forms,  ->         { where(entity_type: 'Partner') }
  scope :user_forms,     ->         { where(entity_type: 'User') }
  scope :not_used_forms, ->(value)  { where.not(id: value) }
  scope :ordered_by,     ->(column) { order(column) }
  scope :order_by_form_title, ->    { order(:form_title) }

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
    User.all.each do |user|
      next if user.strategic_overviewer?
      self.custom_field_permissions.find_or_create_by(user_id: user.id)
    end
  end

  private

  def update_custom_field_label
    labels_update(fields_change.last, fields_was, custom_field_properties)
  end
end
