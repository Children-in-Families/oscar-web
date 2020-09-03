class AddTwoWeeksAssessmentReminderToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :two_weeks_assessment_reminder, :boolean, default: false
  end
end
