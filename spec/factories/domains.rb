FactoryGirl.define do
  factory :domain do
    sequence(:name)  { |n| "AB#{n}" }
    sequence(:identity)  { |n| "#{FFaker::Name.name}-#{n}" }
    description FFaker::Lorem.paragraph
    association :domain_group, factory: :domain_group

    trait :custom do
      custom_domain true
      after(:build) do |domain|
        domain.custom_assessment_setting = create(:custom_assessment_setting, factory: :custom_assessment_setting)
      end
    end
  end
end
