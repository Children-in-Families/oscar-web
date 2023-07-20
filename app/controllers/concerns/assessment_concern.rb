module AssessmentConcern
  def find_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end

  def fix_assessment_domains_attributes
    # assign id to assessment_domain as simply autosave via ajax without updating the form
    return if params.dig(:assessment, :assessment_domains_attributes).blank?

    params[:assessment][:assessment_domains_attributes].each do |index, assessment_domain_attributes|
      domain_id = assessment_domain_attributes[:domain_id]
      assessment_domain = @assessment.assessment_domains.find_by(domain_id: domain_id)
      
      if assessment_domain
        params[:assessment][:assessment_domains_attributes][index] = assessment_domain_attributes.merge(id: assessment_domain.id)
      end
    end
  end
end
