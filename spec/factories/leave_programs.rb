FactoryGirl.define do
  factory :leave_program do
    exit_date '2017-04-01'
    properties { {"e-mail"=>"cif@cambodianfamily.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client_enrollment
    association :program_stream
  end
end
