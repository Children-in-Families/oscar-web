class IndexForeignKeysInCustomAssessmentSettings < ActiveRecord::Migration[5.2]
  def change
    add_index :custom_assessment_settings, :setting_id
  end
end
