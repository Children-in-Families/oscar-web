class AddFieldAssessmentDateToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :assessment_date, :date
    add_index :assessments, :assessment_date
  end
end
