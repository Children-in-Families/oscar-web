FactoryBot.define do
  factory :parent_service, class: Service do
    name  { FFaker::Name.name }
    parent_id { nil }
    association :global_service
  end

  factory :service do
    name { FFaker::Name.name }
    association :global_service
    association :parent, factory: :parent_service
  end
end
