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
    house_number     { FFaker::Address.street_address }
    street_number    { FFaker::Address.street_address }
    status 'Referred'
    school_grade '4'
    relevant_referral_information { FFaker::Lorem.paragraph }
    # code { rand(1000...2000).to_s }
    # sequence(:code){|n| Time.now.to_f.to_s.last(4) + n.to_s }

    association :village, factory: :village
    association :commune, factory: :commune
    association :district, factory: :district
    association :province, factory: :province
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
