class AddDraftToCaseNotes < ActiveRecord::Migration
  def change
    add_column :case_notes, :draft, :boolean, default: true, nil: false
  end
end
