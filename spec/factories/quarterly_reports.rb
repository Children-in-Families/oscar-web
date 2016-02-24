FactoryGirl.define do
  factory :quarterly_report do
    visit_date "2016-02-20"
code ""
cases nil
general_health_or_appearance "MyText"
child_school_attendance_or_progress "MyText"
general_appearance_of_home "MyText"
observations_of_drug_alchohol_abuse "MyText"
describe_if_yes "MyText"
describe_the_family_current_situation "MyText"
has_the_situation_changed_from_the_previous_visit "MyText"
how_did_i_encourage_the_client "MyText"
what_future_teachings_or_trainings_could_help_the_client "MyText"
what_is_my_plan_for_the_next_visit_to_the_client "MyText"
money_and_supplies_being_used_appropriately "MyText"
how_are_they_being_misused "MyText"
staff_id 1
spiritual_developments_with_the_child_or_family "MyText"
  end

end
