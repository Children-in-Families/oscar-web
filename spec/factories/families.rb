FactoryGirl.define do
  factory :family do
    name { Faker::Name.name }
    house { Faker::Address.street_address }
    street { Faker::Address.street_address }
    caregiver_information { Faker::Lorem.paragraph }
    significant_family_members 'MyString'
    household_income 'MyString'
    dependable_income false
    female_children_count 1
    male_children_count 1
    female_adult_count 1
    male_adult_count 1
    first_contract_date { Faker::Date.between(10.months.ago, 2.months.ago) }
  end
end
