FactoryBot.define do
  factory :exit_ngo do
    exit_note FFaker::Lorem.word
    exit_date FFaker::Time.date
    exit_circumstance 'Exited Client'
    exit_reasons ['Client is/moved outside NGO target area (within Cambodia)']

    after(:build) do |exit_ngo|
      exit_ngo.class.skip_callback(:save, :after, :create_exit_ngo_history)
    end

    trait :exit_ngo_with_history do
      after(:build) do |exit_ngo|
        exit_ngo.class.set_callback(:save, :after, :create_exit_ngo_history)
      end
    end
  end
end
