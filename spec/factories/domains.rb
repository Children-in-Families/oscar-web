FactoryGirl.define do
  factory :domain do
    sequence(:name)  { |n| "AB#{n}" }
    sequence(:identity)  { |n| "#{FFaker::Name.name}-#{n}" }
    description FFaker::Lorem.paragraph
    association :domain_group, factory: :domain_group
    association :custom_assessment_setting, factory: :custom_assessment_setting

    trait :custom do
      custom_domain true
    end
  end
end
