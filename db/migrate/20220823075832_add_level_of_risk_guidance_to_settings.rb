class AddLevelOfRiskGuidanceToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :level_of_risk_guidance, :text
  end
end
