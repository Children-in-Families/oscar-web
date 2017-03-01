class PartnerCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :partner
  belongs_to :custom_field

  scope :by_custom_field_id, ->(value) { where(custom_field:  value) }

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
    CustomFieldEmailValidator.new(obj).validate
  end
end
