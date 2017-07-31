module AssessmentHelper
  def order_assessment
    if action_name == 'edit'
      @assessment.assessment_domains_in_order
    end
  end
end
