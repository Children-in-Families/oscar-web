FactoryBot.define do
  factory :quantitative_type do
    sequence(:name)  { |n| "#{FFaker::Name.name}-#{n}" }
  end
end
