class IndexForeignKeysInCaseNotes < ActiveRecord::Migration
  def change
    add_index :case_notes, :assessment_id
  end
end
