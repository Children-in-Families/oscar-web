class AddFieldsToAssessmentDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_domains, :goal_required, :boolean, default: true
    add_column :assessment_domains, :required_task_last, :boolean, default: false
  end
end
