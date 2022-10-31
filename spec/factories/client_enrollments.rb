FactoryBot.define do
  factory :client_enrollment do
    enrollment_date Date.today
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client, factory: :client
    association :program_stream, factory: :program_stream

    after(:build) do |client_enrollment|
      client_enrollment.class.skip_callback(:save, :after, :create_client_enrollment_history)
    end

    factory :client_enrollment_with_history do
      after(:build) do |client_enrollment|
        client_enrollment.class.set_callback(:save, :after, :create_client_enrollment_history)
      end
    end

    trait :active do
      status 'Active'
    end

    trait :exited do
      status 'Exited'
    end
  end
end
