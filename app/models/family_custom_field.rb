class FamilyCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :family
  belongs_to :custom_field

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
  end
end
