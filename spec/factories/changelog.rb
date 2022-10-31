FactoryBot.define do
  factory :changelog do
    sequence(:change_version){ |n| "#{FFaker::Name.name}-#{n}"}
    association :user, factory: :user
  end
end
