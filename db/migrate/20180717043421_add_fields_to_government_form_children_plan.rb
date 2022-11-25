class AddFieldsToGovernmentFormChildrenPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :government_form_children_plans, :score, :integer
    add_column :government_form_children_plans, :comment, :text, default: ''
  end
end
