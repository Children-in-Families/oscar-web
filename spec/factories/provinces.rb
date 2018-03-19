FactoryBot.define do
  factory :province do
    sequence(:name){ |n| "#{FFaker::Name.name}-#{n}"}
    description { FFaker::Lorem.paragraph }
  end
end
