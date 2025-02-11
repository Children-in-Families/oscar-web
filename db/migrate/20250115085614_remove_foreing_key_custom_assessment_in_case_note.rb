class RemoveForeingKeyCustomAssessmentInCaseNote < ActiveRecord::Migration
  def change
    remove_foreign_key :case_notes, column: :custom_assessment_setting_id if foreign_keys(:case_notes).map(&:column).include?('custom_assessment_setting_id')
  end
end
