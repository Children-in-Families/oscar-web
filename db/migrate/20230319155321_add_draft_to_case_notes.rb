class AddDraftToCaseNotes < ActiveRecord::Migration
  def change
    add_column :case_notes, :draft, :boolean, default: false, nil: false
  end
end
