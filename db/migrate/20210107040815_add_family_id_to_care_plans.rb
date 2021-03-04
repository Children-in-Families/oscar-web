class AddFamilyIdToCarePlans < ActiveRecord::Migration
  def change
    add_column :care_plans, :family_id, :integer
    add_index :care_plans, :family_id
  end
end
