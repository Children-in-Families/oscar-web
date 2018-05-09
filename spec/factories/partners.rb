FactoryGirl.define do
  factory :partner do
    name FFaker::Name.name
    address FFaker::Address.street_address
    start_date FFaker::Time.date
    contact_person_name FFaker::Name.name
    contact_person_email FFaker::Internet.email
    contact_person_mobile FFaker::PhoneNumber.phone_number
    affiliation FFaker::Lorem.phrase
    engagement FFaker::Lorem.phrase
    background FFaker::Lorem.paragraph
    association :organization_type, factory: :organization_type
    association :province, factory: :province
  end
end
