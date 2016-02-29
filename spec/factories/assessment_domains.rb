FactoryGirl.define do
  factory :assessment_domain do
    association :assessment, factory: :assessment
    association :domain, factory: :domain
    score { rand(4)+1 }
  end
end
