class AddOtherCaseClosureFieldsToGovernmentForms < ActiveRecord::Migration
  def change
    add_column :government_forms, :other_case_closure, :string
    add_column :government_forms, :brief_case_history, :text
    add_column :government_forms, :case_closure_id, :integer
  end
end
