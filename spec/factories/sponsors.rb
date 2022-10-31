FactoryBot.define do
  factory :sponsor do
    association :client, factory: :client
    association :donor, factory: :donor
  end
end
