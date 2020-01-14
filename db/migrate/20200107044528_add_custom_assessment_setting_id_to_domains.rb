class AddCustomAssessmentSettingIdToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :custom_assessment_setting_id, :integer
  end
end
