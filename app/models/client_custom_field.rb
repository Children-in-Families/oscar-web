class ClientCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :client
  belongs_to :custom_field

  has_paper_trail

  validates :custom_field_id, presence: true

  scope :by_custom_field, ->(value) { where(custom_field:  value) }

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
    CustomFieldEmailValidator.new(obj).validate
  end
end
