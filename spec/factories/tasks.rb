FactoryGirl.define do
  factory :task do
    name FFaker::Name.name
    completion_date FFaker::Time.date
    association :case_note_domain_group, factory: :case_note_domain_group
    association :domain, factory: :domain
    association :client, factory: :client

    trait :incomplete do
      completed false
    end

    trait :complete do
      completed true
    end

    before(:create) do |task|
      task.users << FactoryGirl.create(:user)
    end
  end
end
