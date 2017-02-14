class CustomField < ActiveRecord::Base

  has_many :client_custom_fields
  has_many :clients, through: :client_custom_fields

  has_many :family_custom_fields
  has_many :families, through: :family_custom_fields

  has_many :partner_custom_fields
  has_many :partners, through: :partner_custom_fields

  has_many :user_custom_fields
  has_many :user, through: :user_custom_fields

  validates :entity_name, :form_type, presence: true
  validates :form_type, uniqueness: { case_sensitive: false, scope: :entity_name }

  validate :presence_of_fields

  def presence_of_fields
    if field_objs.empty?
      errors.add(:fields, "can't be blank")
    end
  end

  def field_objs
    JSON.parse(fields) if fields.present?
  end

end
