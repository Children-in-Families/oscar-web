FactoryGirl.define do
  factory :task do
    name FFaker::Name.name
    completion_date FFaker::Time.date
    association :case_note_domain_group, factory: :case_note_domain_group
    association :domain, factory: :domain
    association :client, factory: :client
    association :user, factory: :user

    trait :incomplete do
      completed false
    end

    trait :complete do
      completed true
    end

    trait :overdue do
      completion_date Date.yesterday
    end
  end
end
