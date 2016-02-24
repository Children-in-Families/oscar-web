FactoryGirl.define do
  factory :case_worker do
    first_name { Faker::Name.name }
    last_name { Faker::Name.name }
    start_date { Faker::Date.between(3.years.ago, 2.months.ago) }
    job_title 'Manager'
    department { Faker::Team.name }
    mobile { Faker::PhoneNumber.cell_phone }
    date_of_birth { Faker::Date.between(30.years.ago, 20.years.ago) }
    sequence(:email) { |n| "example#{n}@rotati.com" }
    province nil
  end
end
