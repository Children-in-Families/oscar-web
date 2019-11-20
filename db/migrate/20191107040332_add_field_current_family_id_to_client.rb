class AddFieldCurrentFamilyIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :current_family_id, :integer
    add_index :clients, :current_family_id
  end
end
