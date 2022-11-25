class AddFieldEnableLevelOfRiskToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :enabled_risk_assessment, :boolean, default: false
    add_column :settings, :assessment_type_name, :string, default: 'csi'
  end
end
