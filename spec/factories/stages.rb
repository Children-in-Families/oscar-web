FactoryGirl.define do
  factory :stage do
    sequence(:from_age) { |n| n }
    sequence(:to_age) { |n| n + 1 }
  end
end
