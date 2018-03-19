FactoryBot.define do
  factory :assessment do
    association :client, factory: :client
  end
end
