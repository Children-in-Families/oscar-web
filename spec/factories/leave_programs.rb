FactoryGirl.define do
  factory :leave_program do
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    exit_date FFaker::Time.date
    association :client_enrollment
    association :program_stream
  end
end
