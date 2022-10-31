module SettingsHelper
  def collect_assessment_types
    assessment_types = current_setting.enable_default_assessment ? [[I18n.t('risk_assessments._attr.client_status_index'), 'csi']] : []
    CustomAssessmentSetting.only_enable_custom_assessment.pluck(:custom_assessment_name, :id).each do |arr|
      assessment_types << arr
    end
    assessment_types
  end
end
