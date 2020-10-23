FactoryGirl.define do
  factory :user do
    sequence(:email)  { |n| "#{n}#{FFaker::Internet.email}" }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    password '12345678'
    password_confirmation '12345678'
    roles 'case worker'
    program_warning true
    domain_warning true
    staff_performance_notification true
    task_notify true
    referral_notification false
    mobile '012345678'
    gender 'male'
    preferred_language { 'en' }

    trait :case_worker do
      roles 'case worker'
      after(:create) do |user|
        user.set_manager_ids
      end
    end

    trait :admin do
      roles 'admin'
    end

    trait :strategic_overviewer do
      roles 'strategic overviewer'
    end

    trait :manager do
      roles 'manager'
      after(:create) do |user|
        user.set_manager_ids
      end
    end
  end
end
