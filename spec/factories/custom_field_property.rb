FactoryGirl.define do
  factory :custom_field_property do
     association :custom_formable, factory: :client
     association :custom_field, factory: :custom_field
  end
end
