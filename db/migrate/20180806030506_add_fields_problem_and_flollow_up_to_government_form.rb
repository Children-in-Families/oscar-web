class AddFieldsProblemAndFlollowUpToGovernmentForm < ActiveRecord::Migration
  def change
    add_column :government_forms, :problem, :text, default: ''
    add_column :government_forms, :follow_up_step, :text, default: ''
  end
end
