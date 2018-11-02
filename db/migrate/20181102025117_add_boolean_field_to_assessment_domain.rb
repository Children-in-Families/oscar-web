class AddBooleanFieldToAssessmentDomain < ActiveRecord::Migration
  def change
    add_column :assessment_domains, :goal_required, :boolean, default: true
  end
end
