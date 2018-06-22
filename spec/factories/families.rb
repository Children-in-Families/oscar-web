FactoryGirl.define do
  factory :family do
    name { FFaker::Name.name }
    address { FFaker::Address.street_address }
    caregiver_information { FFaker::Lorem.paragraph }
    significant_family_member_count 1
    household_income 'MyString'
    dependable_income false
    female_adult_count 1
    male_adult_count 1
    contract_date { FFaker::Time.date }
    association :province
    family_type 'Extended Family / Kinship Care'
    status 'Active'

    trait :emergency do
      family_type 'Short Term / Emergency Foster Care'
    end

    trait :foster do
      family_type 'Long Term Foster Care'
    end

    trait :kinship do
      family_type 'Extended Family / Kinship Care'
    end

    trait :birth_family do
      family_type 'Birth Family (Both Parents)'
    end

    trait :inactive do
      family_type 'Long Term Foster Care'
    end
  end
end
