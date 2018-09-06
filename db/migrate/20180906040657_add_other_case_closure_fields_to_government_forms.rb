class AddOtherCaseClosureFieldsToGovernmentForms < ActiveRecord::Migration
  def change
    add_column :government_forms, :other_case_closure, :string
  end
end
