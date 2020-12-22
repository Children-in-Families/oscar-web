class AddPriorityFieldToFamilyPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :family_plans, :priority, :integer
  end
end
