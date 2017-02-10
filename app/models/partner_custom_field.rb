class PartnerCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :partner
  belongs_to :custom_field

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
  end
end
