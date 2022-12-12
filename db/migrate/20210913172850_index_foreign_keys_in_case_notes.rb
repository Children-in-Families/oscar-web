class IndexForeignKeysInCaseNotes < ActiveRecord::Migration[5.2]
  def change
    add_index :case_notes, :assessment_id unless index_exists? :case_notes, :assessment_id
  end
end
