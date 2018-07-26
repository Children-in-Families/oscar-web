FactoryGirl.define do
  factory :village do
    name_kh { FFaker::Name.name }
    name_en { FFaker::Name.name }
    code { FFaker::Address.building_number.to_s }
    association :commune, factory: :commune
  end
end
