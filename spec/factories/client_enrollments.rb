FactoryGirl.define do
  factory :client_enrollment do
    enrollment_date Date.today
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client, factory: :client
    association :program_stream, factory: :program_stream
  end
end
