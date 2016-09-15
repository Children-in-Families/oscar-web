FactoryGirl.define do
  factory :changelog do
    sequence(:version){ |n| "#{FFaker::Name.name}-#{n}"}
    description { FFaker::Lorem.paragraph }
    association :user, factory: :user
  end
end
