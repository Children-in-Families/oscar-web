FactoryGirl.define do
  factory :client do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    date_of_birth { FFaker::Time.date }
    gender 'male'
    current_address { FFaker::Address.street_address }
    status 'Referral'
    school_grade '4'
    relevant_referral_information { FFaker::Lorem.paragraph }
  end
end
