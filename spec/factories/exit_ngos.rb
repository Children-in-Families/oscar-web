FactoryGirl.define do
  factory :exit_ngo do
    exit_note FFaker::Lorem.word
    exit_date FFaker::Time.date
    exit_circumstance 'Exited Client'
    exit_reasons ['Client is/moved outside NGO target area (within Cambodia)']
    association :client, factory: :client
  end
end
