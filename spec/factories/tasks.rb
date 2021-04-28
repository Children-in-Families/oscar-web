FactoryGirl.define do
  factory :task do
    name FFaker::Name.name
    expected_date FFaker::Time.date
    completed { false }
    # association :case_note_domain_group, factory: :case_note_domain_group
    association :domain, factory: :domain
    association :client, factory: :client
    association :user, factory: :user

    after(:build) do |task|
      task.class.skip_callback(:save, :after, :create_task_history)
    end

    trait :task_with_history do
      after(:build) do |task|
        task.class.set_callback(:save, :after, :create_task_history)
      end
    end

    trait :incomplete do
      completed false
    end

    trait :complete do
      completed true
    end

    trait :overdue do
      completion_date Date.yesterday
    end
  end
end
