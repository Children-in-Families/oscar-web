class CreateQuarterlyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :quarterly_reports do |t|
      t.date :visit_date
      t.bigint :code
      t.references :case, index: true, foreign_key: true
      t.text :general_health_or_appearance, default: ''
      t.text :child_school_attendance_or_progress, default: ''
      t.text :general_appearance_of_home, default: ''
      t.text :observations_of_drug_alchohol_abuse, default: ''
      t.text :describe_if_yes, default: ''
      t.text :describe_the_family_current_situation, default: ''
      t.text :has_the_situation_changed_from_the_previous_visit, default: ''
      t.text :how_did_i_encourage_the_client, default: ''
      t.text :what_future_teachings_or_trainings_could_help_the_client, default: ''
      t.text :what_is_my_plan_for_the_next_visit_to_the_client, default: ''
      t.boolean :money_and_supplies_being_used_appropriately, default: false
      t.text :how_are_they_being_misused, default: ''
      t.integer :staff_id
      t.text :spiritual_developments_with_the_child_or_family, default: ''

      t.timestamps null: false
    end
  end
end
