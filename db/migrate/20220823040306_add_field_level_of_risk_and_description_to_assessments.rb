class AddFieldLevelOfRiskAndDescriptionToAssessments < ActiveRecord::Migration
  def change
    add_column :assessments, :level_of_risk, :string
    add_index :assessments, :level_of_risk
    add_column :assessments, :description, :text
  end
end
