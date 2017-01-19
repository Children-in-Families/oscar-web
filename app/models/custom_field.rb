class CustomField < ActiveRecord::Base

  validates :fields, :entity_name, presence: true
  validates :entity_name, uniqueness: { case_sensitive: false }

  def field_objs
    JSON.parse(fields)
  end

  def self.of_client
    find_by(entity_name: 'Client')
  end
end
