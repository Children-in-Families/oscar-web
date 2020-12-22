class AddTwoWeeksAssessmentReminderToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :two_weeks_assessment_reminder, :boolean, default: false
  end
end
