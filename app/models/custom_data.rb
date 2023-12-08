class CustomData < ActiveRecord::Base
  belongs_to :client
  validates :fields, presence: true

  def searchable_fields
    fields.reject { |field| field['type'] == 'file' || field['type'] == 'separateLine' || field['type'] == 'paragraph' || field['type'] == 'textarea' }
  end
end
