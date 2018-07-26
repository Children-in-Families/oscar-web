class RenameFieldInGovernmentFormChildrenPlan < ActiveRecord::Migration
  def change
    rename_column :government_form_children_plans, :when, :completion_date
  end
end
