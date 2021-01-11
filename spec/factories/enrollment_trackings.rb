FactoryGirl.define do
  factory :enrollment_tracking do
    properties { {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :enrollment, factory: :enrollment
    association :tracking, factory: :tracking

    after(:build) do |enrollment_tracking|
      enrollment_tracking.class.skip_callback(:save, :after, :create_entity_enrollment_tracking_history)
    end

    trait :with_history do
      after(:build) do |enrollment_tracking|
        enrollment_tracking.class.set_callback(:save, :after, :create_entity_enrollment_tracking_history)
      end
    end
  end
end
