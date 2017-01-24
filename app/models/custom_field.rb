class CustomField < ActiveRecord::Base

  validates :fields, :entity_name, presence: true
  validates :entity_name, uniqueness: true

  def field_objs
    JSON.parse(fields) if fields.present?
  end
end
