class AddDraftToCaseNotes < ActiveRecord::Migration
  def change
    add_column :case_notes, :draft, :boolean, default: false, null: false
  end
end
