FactoryBot.define do
  factory :case_worker_client do
    association :user, factory: :user, with_deleted: true
    association :client, factory: :client
  end
end
