class CustomFieldPermission < ActiveRecord::Base
  include ClearanceCustomFormConcern
  include ClearanceOverdueConcern

  belongs_to :user_permission, class_name: 'User', foreign_key: :user_id
  belongs_to :user_custom_field_permission, class_name: 'CustomField', foreign_key: :custom_field_id

  scope :order_by_form_title, -> { joins(:user_custom_field_permission).order('lower(custom_fields.form_title)') }
end
