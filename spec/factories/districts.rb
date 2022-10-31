FactoryBot.define do
  factory :district do
    name { FFaker::Name.name }
    code { FFaker::Address.building_number.to_s }
    province { Province.first || association(:province) }
    initialize_with { District.find_or_create_by(name: name) }
  end
end
