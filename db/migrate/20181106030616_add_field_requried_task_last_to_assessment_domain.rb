class AddFieldRequriedTaskLastToAssessmentDomain < ActiveRecord::Migration
  def change
    add_column :assessment_domains, :requried_task_last, :boolean, default: false
  end
end
