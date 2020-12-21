class CreateCustomAssessmentSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_assessment_settings do |t|
      t.string :custom_assessment_name, default: "Custom Assessment"
      t.integer :max_custom_assessment, default: 6
      t.string :custom_assessment_frequency, default: "month"
      t.integer :custom_age, default: 18
      t.integer :setting_id

      t.timestamps null: false
    end
  end
end
