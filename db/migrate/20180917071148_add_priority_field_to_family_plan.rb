class AddPriorityFieldToFamilyPlan < ActiveRecord::Migration
  def change
    add_column :family_plans, :priority, :integer
  end
end
