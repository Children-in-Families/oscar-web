FactoryBot.define do
  factory :parent_service, class: Service do
    name  { FFaker::Name.name }
    parent_id nil
  end

  factory :service do
    name { FFaker::Name.name }
    association :parent, factory: :parent_service
  end
end
