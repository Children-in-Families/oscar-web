FactoryGirl.define do
  factory :organization_type do
    sequence(:name){ |n| "#{FFaker::Name.name}-#{n}"}
  end
end
