FactoryGirl.define do
  factory :client do
    given_name { FFaker::Name.first_name }
    family_name { FFaker::Name.last_name }
    local_given_name { FFaker::Name.first_name }
    local_family_name { FFaker::Name.last_name }
    date_of_birth { FFaker::Time.date }
    initial_referral_date { FFaker::Time.date }
    name_of_referee { FFaker::Name.name }

    gender 'male'
    current_address  { FFaker::Address.street_address }
    house_number     { FFaker::Address.street_address }
    street_number    { FFaker::Address.street_address }
    village          { FFaker::Address.street_address }
    commune          { FFaker::Address.street_address }
    status 'Referred'
    school_grade '4'
    relevant_referral_information { FFaker::Lorem.paragraph }

    association :district, factory: :district
    association :referral_source, factory: :referral_source
    association :received_by, factory: :user

    before(:create) do |client|
      client.users << FactoryGirl.create(:user)
    end

    trait :accepted do
      status 'Accepted'
    end

    trait :exited do
      after(:create) do |client|
        create(:exit_ngo, client: client)
      end
    end

    trait :female do
      gender 'female'
    end
  end
end
