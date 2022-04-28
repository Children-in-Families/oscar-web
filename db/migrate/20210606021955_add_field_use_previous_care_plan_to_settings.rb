class AddFieldUsePreviousCarePlanToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :use_previous_care_plan, :boolean
  end
end
