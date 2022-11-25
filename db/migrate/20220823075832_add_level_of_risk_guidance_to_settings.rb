class AddLevelOfRiskGuidanceToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :level_of_risk_guidance, :text
  end
end
