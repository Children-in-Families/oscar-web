class RiskAssessmentReducer
  attr_reader :type, :risk_assessment, :risk_assessment_params

  def initialize(client, risk_assessment_params, type = 'create')
    @risk_assessment = client.risk_assessment.present? ? client.risk_assessment : client.build_risk_assessment(risk_assessment_params)
    @risk_assessment_params = risk_assessment_params
    @type = type if risk_assessment_params[:assessment_date].present?
  end

  def store
    case type
    when 'create'
      risk_assessment.save
    when 'update'
      risk_assessment.persisted? ? risk_assessment.update_attributes(risk_assessment_params) : risk_assessment.save
    else
      false
    end
  end
end
