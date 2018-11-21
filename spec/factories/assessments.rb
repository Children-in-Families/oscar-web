FactoryGirl.define do
  factory :assessment do
    default true
    association :client, factory: :client
    trait :custom do
      default false
    end
  end
end
