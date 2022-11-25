class AddCustomAssessmentIdToAssessments < ActiveRecord::Migration[5.2]
  def up
    add_column :assessments, :custom_assessment_setting_id, :integer
    add_index :assessments, :custom_assessment_setting_id

    assessment_hash = Assessment.joins(domains: :custom_assessment_setting).select('assessments.id, domains.custom_assessment_setting_id').group('assessments.id, domains.custom_assessment_setting_id').map{|obj| [obj.id, obj.custom_assessment_setting_id ]}.group_by(&:second)
    assessment_hash.keys.each do |key|
      assesmsent_ids = assessment_hash[key]
      values = assesmsent_ids.map do |id, custom_assessment_setting_id|
        "(#{id}, #{custom_assessment_setting_id || 'NULL'})"
      end.join(", ")

      ActiveRecord::Base.connection.execute("UPDATE assessments SET custom_assessment_setting_id = mapping_values.custom_assessment_setting_id FROM (VALUES #{values}) AS mapping_values (assessment_id, custom_assessment_setting_id) WHERE assessments.id = mapping_values.assessment_id") if values.present?
    end
  end

  def down
    remove_index :assessments, :custom_assessment_setting_id
    remove_column :assessments, :custom_assessment_setting_id
  end
end
