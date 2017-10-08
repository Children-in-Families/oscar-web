FactoryGirl.define do
  factory :advanced_search do
    name { FFaker::Name.first_name }
    description { FFaker::Lorem.paragraph }
    queries '{}'
    field_visible '{}'
  end
end
