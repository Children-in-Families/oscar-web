FactoryGirl.define do
  factory :government_form_problem do
    association :government_form, factory: :government_form
    association :problem, factory: :problem
  end
end
