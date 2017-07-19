FactoryGirl.define do
  factory :client_enrollment_tracking do
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client_enrollment, factory: :client_enrollment
    association :tracking, factory: :tracking
  end
end
