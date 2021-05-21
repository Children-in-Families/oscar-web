class AddFieldCaseConferenceIdToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :case_conference_id, :integer
    add_index :assessments, :case_conference_id
  end
end
