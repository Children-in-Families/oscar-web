class UserCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :user
  belongs_to :custom_field

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
    CustomFieldEmailValidator.new(obj).validate
  end

end
