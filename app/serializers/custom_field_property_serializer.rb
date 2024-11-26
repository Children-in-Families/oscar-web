class CustomFieldPropertySerializer < ActiveModel::Serializer
  attributes :id, :properties, :custom_formable_type, :custom_formable_id, :custom_field_id, :attachments, :user_id, :created_at, :updated_at

  has_many :form_builder_attachments
end
