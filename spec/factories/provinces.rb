FactoryGirl.define do
  factory :province do
    sequence(:name){ |n| "#{FFaker::Name.name}-#{n}"}
    initialize_with { Province.find_or_create_by(name: name) }
    description { FFaker::Lorem.paragraph }
    country { 'cambodia' }
  end
end
