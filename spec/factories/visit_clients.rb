FactoryBot.define do
  factory :visit_client do
    association :user, factory: :user
  end
end
