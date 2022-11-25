class AddFamilyIdToCaseNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :case_notes, :family_id, :integer
    add_index :case_notes, :family_id
  end
end
