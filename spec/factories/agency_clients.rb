FactoryBot.define do
  factory :agency_client do
    association :agency, factory: :agency
    association :client, factory: :client
  end
end
