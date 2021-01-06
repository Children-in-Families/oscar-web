FactoryGirl.define do
  factory :enter_ngo do
    accepted_date FFaker::Time.date
    created_at { Time.now }

    after(:build) do |enter_ngo|
      enter_ngo.class.skip_callback(:save, :after, :create_enter_ngo_history)
    end

    trait :client_with_history do
      after(:build) do |enter_ngo|
        enter_ngo.class.set_callback(:save, :after, :create_enter_ngo_history)
      end
    end
  end
end
