FactoryBot.define do
  factory :agency do
    sequence(:name)  { |n| "#{FFaker::Name.name}-#{n}" }
  end
end
