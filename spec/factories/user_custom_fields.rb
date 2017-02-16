FactoryGirl.define do
  factory :user_custom_field do
    properties "MyText"
    user nil
    custom_field nil
  end
end
