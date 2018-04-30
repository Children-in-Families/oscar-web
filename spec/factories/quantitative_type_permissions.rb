FactoryGirl.define do
  factory :quantitative_type_permission do
    association :quantitative_type, factory: :quantitative_type
    association :user, factory: :user
  end
end
