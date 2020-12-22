class AddGoalToAssessmentDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_domains, :goal, :text, default: ''
  end
end
