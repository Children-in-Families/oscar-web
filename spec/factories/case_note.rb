FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    association :client, factory: :client
    association :assessment, factory: :assessment
  end
end
