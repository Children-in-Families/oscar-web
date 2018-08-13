FactoryGirl.define do
  factory :government_form_children_plan do
    goal 'MyString'
    action 'MyString'
    who 'MyString'
    completion_date 'MyString'

    association :government_form, factory: :government_form
    association :children_plan, factory: :children_plan
  end
end
