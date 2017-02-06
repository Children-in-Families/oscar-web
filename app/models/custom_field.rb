class CustomField < ActiveRecord::Base

  has_many :client_custom_fields
  has_many :clients, through: :client_custom_fields

  has_many :family_custom_fields
  has_many :families, through: :family_custom_fields

  has_many :partner_custom_fields
  has_many :partners, through: :partner_custom_fields

  has_many :user_custom_fields
  has_many :user, through: :user_custom_fields

  validates :fields, :entity_name, presence: true
  validates :entity_name, uniqueness: { case_sensitive: false, scope: :form_type }

  def field_objs
    JSON.parse(fields) if fields.present?
  end

  def self.of_client
    find_by(entity_name: 'Client')
  end
end
