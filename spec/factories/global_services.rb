FactoryBot.define do
  factory :global_service do
    uuid { SecureRandom.uuid }
  end
end
