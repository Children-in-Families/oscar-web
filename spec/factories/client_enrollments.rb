FactoryGirl.define do
  factory :client_enrollment do
    properties { {"Select"=>"Option 3", "Text Area"=>"daf", "Text Field"=>"asdf", "Radio Group"=>"Option 2", "Checkbox Group"=>["Option 1", ""]}.to_json }
    association :client, factory: :client
    association :program_stream, factory: :program_stream
  end
end
