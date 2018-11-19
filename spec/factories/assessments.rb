FactoryGirl.define do
  factory :assessment do
    default true
    association :client, factory: :client
  end
end
