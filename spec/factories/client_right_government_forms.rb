FactoryGirl.define do
  factory :client_right_government_form do
    association :client_right, factory: :client_right
    association :government_form, factory: :government_form
  end
end
