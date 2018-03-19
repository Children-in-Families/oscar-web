FactoryBot.define do
  factory :visit do
    association :user, factory: :user
  end
end
