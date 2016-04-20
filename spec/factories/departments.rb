FactoryGirl.define do
  factory :department do
    sequence(:name) { |n| "#{FFaker::Name.name}-#{n}" }
  end
end
