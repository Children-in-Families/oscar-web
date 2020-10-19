FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    attendee { FFaker::Name.name }
    association :client, factory: :client
    association :assessment, factory: :assessment
    association :custom_assessment_setting, factory: :custom_assessment_setting
    interaction_type 'Visit'

    trait :custom do
      custom true
    end

    after(:create) do |cn|
      cn.domain_groups << FactoryGirl.create(:domain_group)
    end
  end
end
