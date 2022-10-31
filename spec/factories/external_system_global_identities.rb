FactoryBot.define do
  factory :external_system_global_identity do
    association :external_system
    association :global_identity
    external_id ""
    client_slug ""
    organization_name 'app'
  end
end
