FactoryGirl.define do
  factory :client_custom_field do
    properties "MyText"
    client nil
    custom_field nil
  end
end
