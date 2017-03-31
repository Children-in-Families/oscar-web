class CustomField < ActiveRecord::Base

  has_many :client_custom_fields, dependent: :restrict_with_error
  has_many :clients, through: :client_custom_fields

  has_many :family_custom_fields, dependent: :restrict_with_error
  has_many :families, through: :family_custom_fields

  has_many :partner_custom_fields, dependent: :restrict_with_error
  has_many :partners, through: :partner_custom_fields

  has_many :user_custom_fields, dependent: :restrict_with_error
  has_many :user, through: :user_custom_fields

  validates :entity_type, :form_title, presence: true
  validates :form_title, uniqueness: { case_sensitive: false, scope: :entity_type }
  validates :time_of_frequency, presence: true,
                                numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: 'frequency.present?'
  validate :presence_of_fields
  validate :uniq_fields

  before_save :set_time_of_frequency

  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Family', 'Partner', 'User'].freeze

  def set_time_of_frequency
    if frequency.present?
      self.time_of_frequency = time_of_frequency
    else
      self.time_of_frequency = 0
    end
  end

  def uniq_fields
    labels = field_objs.collect do |object|
      object['label']
    end
    duplicate = labels.detect{ |e| labels.count(e) > 1 }
    if duplicate.present?
      errors.add(:fields, I18n.t('must_be_uniq'))
    end
  end

  def presence_of_fields
    if field_objs.empty?
      errors.add(:fields, I18n.t('cannot_be_blank'))
    end
  end

  def has_no_association?
    client_custom_fields.empty? || family_custom_fields.empty? || partner_custom_fields.empty? || user_custom_fields.empty?
  end

  def field_objs
    fields.present? ? JSON.parse(fields) : fields
  end
end
