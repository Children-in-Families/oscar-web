class AddFamilyIdToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :family_id, :integer
    add_index :goals, :family_id
  end
end
