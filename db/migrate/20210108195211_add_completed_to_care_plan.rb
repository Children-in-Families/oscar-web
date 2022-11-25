class AddCompletedToCarePlan < ActiveRecord::Migration[5.2]
  def change
    add_column :care_plans, :completed, :boolean, default: false
  end
end
