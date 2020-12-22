class AddCaseNoteIdToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :case_note_id, :string, default: ''
  end
end
