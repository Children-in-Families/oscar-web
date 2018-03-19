FactoryBot.define do
  factory :district do
    name { FFaker::Name.name }
    association :province, factory: :province
  end
end
