FactoryBot.define do
  factory :organization do
    full_name { FFaker::Name.name }
    sequence(:short_name) { |n| "#{n}-cif" }
  end
end
