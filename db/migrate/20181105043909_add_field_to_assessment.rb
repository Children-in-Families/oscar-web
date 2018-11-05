class AddFieldToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :requried_task_last, :boolean, default: false
  end
end
