FactoryGirl.define do
  factory :setting do

    trait :month do
      assessment_frequency 'month'
    end

    trait :week do
      assessment_frequency 'week'
    end

    trait :day do
      assessment_frequency 'day'
    end

    min_assessment { rand(3..12)}
    max_assessment { rand(6..12)}
  end
end
