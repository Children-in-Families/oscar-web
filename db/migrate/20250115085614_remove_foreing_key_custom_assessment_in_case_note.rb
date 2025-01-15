class RemoveForeingKeyCustomAssessmentInCaseNote < ActiveRecord::Migration
  def change
    remove_foreign_key :case_notes, column: :custom_assessment_setting_id
  end
end
