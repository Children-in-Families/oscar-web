module AssessmentConcern
  def find_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def add_more_attachments(new_file, assessment_domain_id)
    return unless new_file.present?

    assessment_domain = AssessmentDomain.find(assessment_domain_id)
    files = assessment_domain.attachments
    files += new_file
    assessment_domain.attachments = files
    assessment_domain.save
  end
end
