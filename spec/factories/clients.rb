FactoryGirl.define do
  factory :client do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    date_of_birth { Faker::Date.forward(23) }
    gender 'Male'
    current_address { Faker::Address.street_address }
    status 'Referral'
    school_grade '4'
    care_details { Faker::Lorem.paragraph }
    referral_date { Faker::Date.between(10.months.ago, 1.month.ago) }
    referral_follow_up_date { Faker::Date.between(10.months.ago, 1.month.ago) }
  end
end
