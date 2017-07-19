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

    trait :emergency do
      family_type 'emergency'
    end

    trait :foster do
      family_type 'foster'
    end

    trait :kinship do
      family_type 'kinship'
    end

    trait :birth_family do
      family_type 'birth_family'
    end

    trait :inactive do
      family_type 'inactive'
    end
  end
end
