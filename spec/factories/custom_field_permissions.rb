FactoryGirl.define do
  factory :custom_field_permission do
    association :custom_field, factory: :custom_field
    association :user, factory: :user
  end
end
