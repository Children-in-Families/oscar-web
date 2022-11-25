class AddedFieldHideCaseNoteNoteToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :hide_case_note_note, :boolean, default: false
  end
end
