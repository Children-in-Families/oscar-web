class AddNoteToFamilyMembers < ActiveRecord::Migration
  def change
    add_column :family_members, :note, :text
  end
end
