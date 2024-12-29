class CustomFieldSerializer < ActiveModel::Serializer
  attributes :id, :entity_type, :properties, :form_title, :frequency, :time_of_frequency, :ngo_name, :fields, :hidden, :created_at, :updated_at
end
