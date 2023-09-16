class AssessmentDomainsLoader < ServiceBase
  attr_reader :assessment

  def initialize(assessment)
    @assessment = assessment
  end

  def call
    return assessment.assessment_domains if assessment.persisted? || assessment.client_id.blank?

    domains.map do |domain|
      case_conference_domain = assessment.case_conference.case_conference_domains.find_by(domain_id: domain.id) if assessment.case_conference
      AssessmentDomain.new(domain: domain, reason: case_conference_domain&.presenting_problem)
    end
  end

  private

  def domains
    @domains ||= if assessment.default?
      Domain.csi_domains
    else
      if assessment.custom_assessment_setting_id
        CustomAssessmentSetting.find_by(id: assessment.custom_assessment_setting_id).domains
      else
        Domain.custom_csi_domains
      end
    end
  end
end
