FactoryBot.define do
  factory :assessment_domain do
    association :assessment, factory: :assessment
    association :domain, factory: :domain
    score { rand(4)+1 }
    reason FFaker::Lorem.paragraph
    goal FFaker::Lorem.paragraph
  end
end
