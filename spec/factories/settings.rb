FactoryGirl.define do
  factory :setting do
    # min_assessment 3
    max_assessment 6
    max_case_note 30
    case_note_frequency 'day'
    enable_default_assessment true
    enable_custom_assessment true
    custom_assessment_frequency 'month'
    max_custom_assessment 6
    default_assessment 'CSI Assessment'
    country_name 'cambodia'
    age 18
    association :commune, factory: :commune

    trait :yearly_assessment do
      assessment_frequency 'year'
    end

    trait :monthly_assessment do
      assessment_frequency 'month'
    end

    trait :weekly_assessment do
      assessment_frequency 'week'
    end

    trait :daily_assessment do
      assessment_frequency 'day'
    end

    trait :yearly_casenote do
      case_note_frequency 'year'
    end

    trait :monthly_casenote do
      case_note_frequency 'month'
    end

    trait :weekly_casenote do
      case_note_frequency 'week'
    end

    trait :daily_casenote do
      case_note_frequency 'day'
    end
  end
end
