class AddFieldsToGovernmentFormChildrenPlan < ActiveRecord::Migration
  def change
    add_column :government_form_children_plans, :score, :integer
    add_column :government_form_children_plans, :comment, :text, default: ''
  end
end
