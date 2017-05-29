FactoryGirl.define do
  factory :custom_field do
    entity_type 'Client'
    fields [{'type'=>'text', 'label'=>'Hello World'}].to_json
    form_title FFaker::Name.name
  end
end
