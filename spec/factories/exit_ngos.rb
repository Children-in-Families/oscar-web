FactoryGirl.define do
  factory :exit_ngo do
    exit_note FFaker::Lorem.word
    exit_date FFaker::Time.date
    exit_circumstance 'Exited Client'
  end
end
