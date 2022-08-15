class AddedFieldHideCaseNoteNoteToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :hide_case_note_note, :boolean, default: false
  end
end
