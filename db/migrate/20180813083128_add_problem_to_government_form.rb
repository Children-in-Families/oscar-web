class AddProblemToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :problem, :text, default: ''
  end
end
