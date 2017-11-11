FactoryGirl.define do
  factory :custom_field do
    entity_type 'Client'
    fields [{'type'=>'text', 'label'=>'Name'}].to_json
    form_title { FFaker::Lorem.word }
  end
end
