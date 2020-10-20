FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    attendee { FFaker::Name.name }
    association :client, factory: :client
    association :assessment, factory: :assessment
    association :custom_assessment_setting, factory: :custom_assessment_setting
    interaction_type 'Visit'

    after :build do |cn|
      cn.case_note_domain_groups.build(domain_group: create(:domain_group))
    end

    trait :custom do
      custom true
    end
  end
end
