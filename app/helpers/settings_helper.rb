module SettingsHelper
  def collect_assessment_types
    assessment_types = [[I18n.t('settings._attr.client_status_index'), 'csi']]
    CustomAssessmentSetting.only_enable_custom_assessment.pluck(:custom_assessment_name, :id).each do |arr|
      assessment_types << arr
    end
    assessment_types
  end
end
