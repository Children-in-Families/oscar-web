FactoryGirl.define do
  factory :client do
    given_name { FFaker::Name.first_name }
    family_name { FFaker::Name.last_name }
    local_given_name { FFaker::Name.first_name }
    local_family_name { FFaker::Name.last_name }
    date_of_birth { FFaker::Time.date }
    gender 'male'
    current_address { FFaker::Address.street_address }
    house_number    { FFaker::Address.street_address }
    street_number   { FFaker::Address.street_address }
    village         { FFaker::Address.street_address }
    commune         { FFaker::Address.street_address }
    district        { FFaker::Address.street_address }
    status 'Referral'
    school_grade '4'
    relevant_referral_information { FFaker::Lorem.paragraph }
  end
end
