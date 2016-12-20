FactoryGirl.define do
  factory :case do
    start_date FFaker::Time.date
    carer_names FFaker::Name.name
    carer_address FFaker::Address.street_address
    exited false
    association :family, factory: :family
    # association :client, factory: :client
    association :province, factory: :province
    association :partner, factory: :partner

    trait :inactive do
      exited true
      exit_date { Time.now }
      exit_note FFaker::Lorem.paragraph
    end
  end
end
