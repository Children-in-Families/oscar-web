FactoryGirl.define do
  factory :setting do
    disable_assessment false

    trait :monthly_assessment do
      assessment_frequency 'month'
    end

    trait :weekly_assessment do
      assessment_frequency 'week'
    end

    trait :daily_assessment do
      assessment_frequency 'day'
    end

    min_assessment { rand(3..12)}
    max_assessment { rand(6..12)}
  end
end
