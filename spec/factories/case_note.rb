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

    after :create do |cn|
      domain_group_list = create_list(:domain_group, 3)
      create :case_note_domain_group, case_note: cn, domain_group: domain_group_list.first
      create :case_note_domain_group, case_note: cn, domain_group: domain_group_list.second
      create :case_note_domain_group, case_note: cn, domain_group: domain_group_list.third
    end
  end
end
