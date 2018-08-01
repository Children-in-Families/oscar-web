FactoryGirl.define do
  factory :government_form_need do
    association :government_form, factory: :government_form
    association :need, factory: :need
  end
end
