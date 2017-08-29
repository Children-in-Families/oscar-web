FactoryGirl.define do
  factory :case_worker_client do
    association :user, factory: :user
    association :client, factory: :client
  end
end