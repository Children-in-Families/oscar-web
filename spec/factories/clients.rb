FactoryBot.define do
  factory :client do
    given_name { FFaker::Name.first_name }
    family_name { FFaker::Name.last_name }
    local_given_name { FFaker::Name.first_name }
    local_family_name { FFaker::Name.last_name }
    date_of_birth { FFaker::Time.date }
    initial_referral_date { FFaker::Time.date }
    name_of_referee { FFaker::Name.name }
    gender { 'male' }
    house_number     { FFaker::Address.street_address }
    street_number    { FFaker::Address.street_address }
    status { "Referred" }
    school_grade { '4' }
    relevant_referral_information { FFaker::Lorem.paragraph }
    referral_source_category_id { 4 }

    association :global_identity
    association :received_by, factory: :user

    before(:create) do |client|
      client.users << FactoryBot.create(:user)
    end

    after(:build) do |client|
      client.class.skip_callback(:save, :after, :create_client_history, :mark_referral_as_saved, :global_identity_organizations)
      client.stub(:generate_random_char).and_return('abcd')
    end

    trait :client_with_history do
      after(:build) do |client|
        client.class.set_callback(:save, :after, :create_client_history)
      end
    end

    trait :with_referral_source do
      association :referral_source, factory: :referral_source
    end

    trait :with_village do
      association :village, factory: :village
      association :commune, factory: :commune
      association :district, factory: :district
      association :province, factory: :province
    end

    trait :accepted do
      status {'Accepted'}
    end

    trait :exited do
      after(:create) do |client|
        create(:exit_ngo, client: client)
      end
    end

    trait :female do
      gender { 'female' }
    end
  end
end
