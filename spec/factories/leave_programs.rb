FactoryBot.define do
  factory :leave_program do
    properties {
        {"e-mail"=>"test@example.com",
        "age"=>"3",
        "description"=>"this is testing"
      }.to_json
    }
    exit_date {  Date.today }
    association :client_enrollment
    association :program_stream

    after(:build) do |leave_program|
      leave_program.class.skip_callback(:save, :after, :create_leave_program_history)
    end

    trait :leave_program_with_history do
      after(:build) do |leave_program|
        leave_program.class.set_callback(:save, :after, :create_leave_program_history)
      end
    end
  end
end
