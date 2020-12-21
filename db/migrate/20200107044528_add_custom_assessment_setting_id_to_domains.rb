class AddCustomAssessmentSettingIdToDomains < ActiveRecord::Migration[5.2]
  def change
    add_column :domains, :custom_assessment_setting_id, :integer
  end
end
