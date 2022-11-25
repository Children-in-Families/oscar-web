class AddFamilyIdToGoals < ActiveRecord::Migration[5.2]
  def change
    add_column :goals, :family_id, :integer
    add_index :goals, :family_id
  end
end
