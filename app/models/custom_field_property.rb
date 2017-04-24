class CustomFieldProperty < ActiveRecord::Base
  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field

  scope :by_custom_field,                   -> (value) { where(custom_field:  value) }
  scope :most_recents,                      ->         { order('created_at desc') }
end
