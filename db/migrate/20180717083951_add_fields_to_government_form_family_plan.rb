class AddFieldsToGovernmentFormFamilyPlan < ActiveRecord::Migration
  def change
    add_column :government_form_family_plans, :score, :integer
    add_column :government_form_family_plans, :comment, :text, default: ''
  end
end
