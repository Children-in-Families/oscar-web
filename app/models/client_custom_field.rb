class ClientCustomField < ActiveRecord::Base
  include CustomFieldProperties

  belongs_to :client
  belongs_to :custom_field

  validate do |obj|
    CustomFieldPresentValidator.new(obj).validate
    CustomFieldNumericalityValidator.new(obj).validate
  end
end
