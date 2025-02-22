class ClientCustomDataSerializer < ActiveModel::Serializer
  attributes :id, :properties, :client_id, :custom_data_id, :created_at, :updated_at

  has_many :form_builder_attachments
end
