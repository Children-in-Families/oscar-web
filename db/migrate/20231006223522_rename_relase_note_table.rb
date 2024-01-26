class RenameRelaseNoteTable < ActiveRecord::Migration
  def change
    rename_table :relase_notes, :release_notes
  end
end
