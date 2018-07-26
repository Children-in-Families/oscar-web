FactoryGirl.define do
  factory :government_form_family_plan do
    goal "MyString"
    action "MyString"
    result "MyString"

    association :government_form, factory: :government_form
    association :family_plan, factory: :family_plan
  end
end
