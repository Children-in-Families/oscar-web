FactoryGirl.define do
  factory :changelog do
    sequence(:version){ |n| "#{FFaker::Name.name}-#{n}"}
    description { FFaker::Lorem.paragraph }
  end
end
