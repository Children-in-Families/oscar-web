FactoryGirl.define do
  factory :government_form_service_type do
    association :government_form, factory: :government_form
    association :service_type, factory: :service_type
  end
end
