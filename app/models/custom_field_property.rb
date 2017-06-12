class CustomFieldProperty < ActiveRecord::Base
  mount_uploaders :attachments, CustomFieldPropertyUploader

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field

  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }

  has_paper_trail

  validates :custom_field_id, presence: true
  validate do |obj|
    CustomFormPresentValidator.new(obj, 'custom_field', 'fields').validate
    CustomFormNumericalityValidator.new(obj, 'custom_field', 'fields').validate
    CustomFormEmailValidator.new(obj, 'custom_field', 'fields').validate
  end
end
