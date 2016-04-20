FactoryGirl.define do
  factory :domain do
    sequence(:name)  { |n| n }
    sequence(:identity)  { |n| "#{FFaker::Name.name}-#{n}" }
    description FFaker::Lorem.paragraph
    association :domain_group, factory: :domain_group
  end
end
