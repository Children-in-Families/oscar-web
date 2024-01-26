class FixCustomSettingId < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Assessment.unscoped do
          Assessment.customs.where("created_at >= ? AND custom_assessment_setting_id IS NULL", "2023-07-17").each do |assessment|
            domain = assessment.domains.last
            next if domain.blank?

            assessment.update_columns(custom_assessment_setting_id: domain.custom_assessment_setting_id)
          end
        end
      end
    end
  end
end
