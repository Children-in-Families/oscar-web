FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    attendee { FFaker::Name.name }
    association :client, factory: :client
    association :assessment, factory: :assessment
    interaction_type 'Visit'

    trait :custom do
      custom true
    end
  end
end
