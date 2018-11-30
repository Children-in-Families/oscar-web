FactoryGirl.define do
  factory :province do
    sequence(:name){ |n| "#{FFaker::Name.name} / #{n}"}
    description { FFaker::Lorem.paragraph }
    country 'cambodia'
  end
end
