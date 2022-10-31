FactoryBot.define do
  factory :client_enrollment_tracking do
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client_enrollment, factory: :client_enrollment
    association :tracking, factory: :tracking

    after(:build) do |client_enrollment_tracking|
      client_enrollment_tracking.class.skip_callback(:save, :after, :create_client_enrollment_tracking_history)
    end

    trait :client_with_history do
      after(:build) do |client_enrollment_tracking|
        client_enrollment_tracking.class.set_callback(:save, :after, :create_client_enrollment_tracking_history)
      end
    end
  end
end
