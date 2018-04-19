FactoryGirl.define do
  factory :enter_ngo do
    accepted_date FFaker::Time.date
    association :client, factory: :client
  end
end
