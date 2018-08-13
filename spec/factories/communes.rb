FactoryGirl.define do
  factory :commune do
    name_kh { FFaker::Name.name }
    name_en { FFaker::Name.name }
    code { FFaker::Address.building_number.to_s }
    association :district, factory: :district
  end
end
