namespace :custom_assessment do
  desc "Reassociate the custom_assessment"
  task reassociate: :environment do
    Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
      Organization.switch_to short_name
      custom_assessment_setting_id = CustomAssessmentSetting.first&.id
      custom_domains = Domain.where("custom_domain = true AND created_at <= '2020-02-13'")
      setting_id = Setting.first&.id
      if custom_domains.present? && setting_id && custom_assessment_setting_id.nil?
        custom_assessment_setting = CustomAssessmentSetting.create(custom_assessment_name: "Custom Assessment", max_custom_assessment: 6, custom_assessment_frequency: "month", custom_age: 18, setting_id: setting_id, enable_custom_assessment: true)
        custom_assessment_setting_id = custom_assessment_setting.id
      end
      custom_domains.update_all(custom_assessment_setting_id: custom_assessment_setting_id) if custom_assessment_setting_id && custom_domains.present?
      puts "#{short_name} done!" if custom_assessment_setting_id && custom_domains.present?
    end
    puts "Done!!!!"
  end

end
