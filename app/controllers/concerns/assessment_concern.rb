module AssessmentConcern
  def find_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end
end
