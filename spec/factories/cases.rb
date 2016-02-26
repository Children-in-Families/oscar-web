FactoryGirl.define do
  factory :case do
    start_date FFaker::Time.date
    carer_names FFaker::Name.name
    carer_address FFaker::Address.street_address
    association :family, factory: :family
  end
end
