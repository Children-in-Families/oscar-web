FactoryGirl.define do
  factory :enrollment do
    enrollment_date Date.today
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :programmable, factory: :family
    association :program_stream, factory: :program_stream

    after(:build) do |enrollment|
      enrollment.class.skip_callback(:save, :after, :create_enrollment_history)
    end

    factory :enrollment_with_history do
      after(:build) do |enrollment|
        enrollment.class.set_callback(:save, :after, :create_enrollment_history)
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
