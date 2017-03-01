FactoryGirl.define do
  factory :custom_field do
    entity_type "MyString"
    fields ['input': 'text'].to_json
    form_title 'MyString'
  end
end
