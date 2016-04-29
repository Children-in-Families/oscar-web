FactoryGirl.define do
  factory :task do
    name FFaker::Name.name
    completion_date FFaker::Time.date
    association :user, factory: :user
    association :case_note_domain_group, factory: :case_note_domain_group
    association :domain, factory: :domain
    association :client, factory: :client
  end
end

