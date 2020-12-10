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
    association :village, factory: :village
    association :commune, factory: :commune
    association :district, factory: :district
    association :province, factory: :province
    family_type 'Extended Family / Kinship Care'
    status 'Active'
    street { FFaker::Address.street_address }
    house { FFaker::Address.street_address }
    sequence(:code){|n| Time.now.to_f.to_s.last(4) + n.to_s }

    after(:build) do |family|
      family.cases.skip_callback(:save, :after, :create_client_history)
    end

    trait :emergency do
      family_type 'Short Term / Emergency Foster Care'
    end

    trait :foster do
      family_type 'Long Term Foster Care'
    end

    trait :kinship do
      family_type 'Extended Family / Kinship Care'
    end

    trait :birth_family_both_parents do
      family_type 'Birth Family (Both Parents)'
    end

    trait :other do
      family_type 'Other'
    end

    trait :active do
      status 'Active'
    end

    trait :inactive do
      status 'Inactive'
    end

    trait :exited do
      status 'Exited'
    end

    trait :referred do
      status 'Referred'
    end
  end
end
