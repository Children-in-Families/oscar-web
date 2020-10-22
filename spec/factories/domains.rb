FactoryGirl.define do
  factory :domain do
    sequence(:name)  { |n| "AB#{n}" }
    sequence(:identity)  { |n| "#{FFaker::Name.name}-#{n}" }
    description FFaker::Lorem.paragraph
    association :domain_group, factory: :domain_group

    trait :custom do
      custom_domain { true }
      association :custom_assessment_setting, factory: :custom_assessment_setting
    end


  end
end
