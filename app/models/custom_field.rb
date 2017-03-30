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

  before_save :set_time_of_frequency, :set_ngo_name

  FREQUENCIES  = ['Daily', 'Weekly', 'Monthly', 'Yearly'].freeze
  ENTITY_TYPES = ['Client', 'Family', 'Partner', 'User'].freeze

  def self.custom_fields_in_tenant(tenant_name)
    Organization.switch_to tenant_name
    all
  end

  def set_time_of_frequency
    if frequency.present?
      self.time_of_frequency = time_of_frequency
    else
      self.time_of_frequency = 0
    end
  end

  def set_ngo_name
    if ngo_name.blank?
      self.ngo_name = Organization.current.full_name
    end
  end

  def presence_of_fields
    if field_objs.empty?
      errors.add(:fields, "can't be blank")
    end
  end

  def field_objs
    fields.present? ? JSON.parse(fields) : fields
  end
end
