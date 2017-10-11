class CustomFieldPermission < ActiveRecord::Base
  belongs_to :user_permission, class_name: 'User', foreign_key: :user_id
  belongs_to :user_custom_field_permission, class_name: 'CustomField', foreign_key: :custom_field_id
end
