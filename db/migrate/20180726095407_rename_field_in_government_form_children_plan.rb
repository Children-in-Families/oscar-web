class RenameFieldInGovernmentFormChildrenPlan < ActiveRecord::Migration
  def up
    remove_column :government_form_children_plans, :when
    add_column :government_form_children_plans, :completion_date, :date
  end

  def down
    add_column :government_form_children_plans, :when, :string, default: ''
    remove_column :government_form_children_plans, :completion_date
  end
end
