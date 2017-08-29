FactoryGirl.define do
  factory :quantitative_case do
    sequence(:value)  { |n| "#{FFaker::Name.name}-#{n}" }
    association :quantitative_type, factory: :quantitative_type
  end
end
