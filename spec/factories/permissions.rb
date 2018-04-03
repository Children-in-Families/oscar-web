FactoryGirl.define do
  factory :permission do
    association :user, factory: :user
  end
end
