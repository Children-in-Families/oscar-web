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

  def upload_attachment
    assessment_domain = @assessment.assessment_domains.find_or_initialize_by(domain_id: params[:domain_id])
    assessment_domain.save(validate: false)
    attachments = params.dig('assessment', 'assessment_domains_attributes').map do |_index, assessment_domain_attributes|
      assessment_domain_attributes[:attachments]
    end.flatten.compact

    if attachments.any?
      files = assessment_domain.attachments
      files += attachments
      assessment_domain.attachments = files
      assessment_domain.save(validate: false)
    end

    render json: { message: t('.successfully_uploaded') }, status: '200'
  end
end
