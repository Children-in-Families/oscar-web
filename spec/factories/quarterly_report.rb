FactoryBot.define do
  factory :quarterly_report do
    visit_date { FFaker::Time.date }
    code { rand(10 ** 8) }
    general_health_or_appearance { FFaker::Lorem.paragraph }
    child_school_attendance_or_progress { FFaker::Lorem.paragraph }
    general_appearance_of_home { FFaker::Lorem.paragraph }
    observations_of_drug_alchohol_abuse { FFaker::Lorem.paragraph }
    describe_if_yes { FFaker::Lorem.paragraph }
    describe_the_family_current_situation { FFaker::Lorem.paragraph }
    has_the_situation_changed_from_the_previous_visit { FFaker::Lorem.paragraph }
    how_did_i_encourage_the_client { FFaker::Lorem.paragraph }
    what_is_my_plan_for_the_next_visit_to_the_client { FFaker::Lorem.paragraph }
    money_and_supplies_being_used_appropriately { FFaker::Boolean.random }
    how_are_they_being_misused { FFaker::Lorem.paragraph }
    association :staff_information, factory: :user
    association :case, factory: :case
    spiritual_developments_with_the_child_or_family { FFaker::Lorem.paragraph }
  end
end
