class AddFieldUsePreviousCarePlanToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :use_previous_care_plan, :boolean
  end
end
