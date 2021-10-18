class IndexForeignKeysInCustomAssessmentSettings < ActiveRecord::Migration
  def change
    add_index :custom_assessment_settings, :setting_id
  end
end
