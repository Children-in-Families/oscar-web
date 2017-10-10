class CustomFieldPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_custom_field_permissions, class_name: 'CustomField', foreign_key: :custom_field_id
end
