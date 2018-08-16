class AddAssessmentCaseNoteToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :assessment, index: true, foreign_key: true
    add_reference :tasks, :case_note, index: true, foreign_key: true
  end
end
