FactoryGirl.define do
  factory :assessment do
    association :client, factory: :client
    
    trait :with_assessment_domain do
      assessment_domains { [build(:assessment_domain, assessment: nil, goal: '', reason: '')] }
    end
  end
end
