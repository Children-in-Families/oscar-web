class AddGoalToAssessmentDomain < ActiveRecord::Migration
  def change
    add_column :assessment_domains, :goal, :text, default: ''
  end
end
