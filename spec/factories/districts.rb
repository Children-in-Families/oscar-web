FactoryGirl.define do
  factory :district do
    name { FFaker::Name.name }
    code { FFaker::Address.building_number.to_s }
    association :province, factory: :province
  end
end
