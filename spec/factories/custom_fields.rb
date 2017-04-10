FactoryGirl.define do
  factory :custom_field do
    entity_type FFaker::Name.name
    fields ['input': 'text'].to_json
    form_title FFaker::Name.name
  end
end
