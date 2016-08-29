FactoryGirl.define do
  factory :survey do
    association :client, factory: :client
  end
end
