class AddCaseNoteIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :case_note_id, :string, default: ''
  end
end
