FactoryGirl.define do
  factory :client_enrollment do
    enrollment_date '2017-04-01'
    properties { {"e-mail"=>"cif@cambodianfamily.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client, factory: :client
    association :program_stream, factory: :program_stream
  end
end
