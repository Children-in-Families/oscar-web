class AddFieldsToGovernmentFormFamilyPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :government_form_family_plans, :score, :integer
    add_column :government_form_family_plans, :comment, :text, default: ''
  end
end
