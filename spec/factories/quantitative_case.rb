FactoryGirl.define do
  factory :quantitative_case do
    value FFaker::Lorem.sentence
    association :quantitative_type, factory: :quantitative_type
  end
end
