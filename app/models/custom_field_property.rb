class CustomFieldProperty < ActiveRecord::Base
  # mount_uploaders :attachments, CustomFieldPropertyUploader
  FILE_EXTENSIONS = ['.doc', '.docx', '.xls', '.xlsx', '.pdf'].freeze

  belongs_to :custom_formable, polymorphic: true
  belongs_to :custom_field
  has_many :attachments, dependent: :destroy

  accepts_nested_attributes_for :attachments

  scope :by_custom_field, -> (value) { where(custom_field:  value) }
  scope :most_recents,    ->         { order('created_at desc') }

  has_paper_trail

  validates :custom_field_id, presence: true
  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
    CustomFieldEmailValidator.new(obj).validate
  end
end
