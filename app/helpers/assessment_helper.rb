module AssessmentHelper
  def assessment_edit_link(client, assessment)
    if assessment_editable? 
      link_to(edit_client_assessment_path(@assessment.client, @assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if(false, edit_client_assessment_path(@assessment.client, @assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def order_assessment
    if action_name == 'edit'
      @assessment.assessment_domains_in_order
    end
  end

  def assessment_readable?
    permission = current_user.permission
    permission.nil? ? true : permission.assessments_readable ? true : false
  end

  def assessment_editable?
    permission = current_user.permission
    permission.nil? ? true : permission.assessments_editable ? true : false
  end
end
