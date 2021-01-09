class AddCompletedToCarePlan < ActiveRecord::Migration
  def change
    add_column :care_plans, :completed, :boolean, default: false
  end
end
