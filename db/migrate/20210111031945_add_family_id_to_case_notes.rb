class AddFamilyIdToCaseNotes < ActiveRecord::Migration
  def change
    add_column :case_notes, :family_id, :integer
    add_index :case_notes, :family_id
  end
end
