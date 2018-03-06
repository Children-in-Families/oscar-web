FactoryGirl.define do
  factory :custom_field do
    entity_type 'Client'
    fields [{'type'=>'text', 'label'=>'Name'}].to_json
    sequence(:form_title)  { |n| "#{FFaker::Lorem.word}#{n}" }
  end
end
