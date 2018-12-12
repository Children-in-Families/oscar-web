FactoryGirl.define do
  factory :assessment do
    default true
    association :client, factory: :client

    trait :with_assessment_domain do
      assessment_domains { [build(:assessment_domain, assessment: nil, goal: '', reason: '')] }
    end

    trait :custom do
      default false
    end
  end
end
