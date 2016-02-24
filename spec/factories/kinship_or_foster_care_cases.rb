FactoryGirl.define do
  factory :kinship_or_foster_care_case do
    status { ['Active - Support', 'Active - Visit Only', 'Fully Independent', 'Passed Away'].sample }
    able false
    support_ammount {  Faker::Number.number(3) }
    support_notes { Faker::Lorem.paragraph }
    initial_assessment_date { Faker::Date.between(6.months.ago, 2.months.ago) }
    start_date { Faker::Date.between(10.months.ago, 6.months.ago) }
    end_date { Faker::Date.between(10.months.ago, 1.month.ago) }
    reason_for_exit { Faker::Lorem.paragraph }
    case_length 1

    trait :kc do
      type 'KC'
    end

    trait :fc do
      type 'FC'
    end
  end
end
