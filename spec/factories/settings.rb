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

    min_assessment { rand(1..9)}
    max_assessment { rand(1..9)}
  end
end
