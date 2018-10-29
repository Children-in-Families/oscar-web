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
    return true if current_user.admin? || current_user.strategic_overviewer?
    current_user.permission.assessments_readable
  end

  def assessment_editable?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.permission.assessments_editable
  end

  def assessment_completed_date(assessment)
    if assessment.completed?
      completed_date = PaperTrail::Version.where(item_type: 'Assessment', item_id: assessment.id).where_object_changes(completed: true).last.created_at
    else
      completed_date = assessment.created_at
    end
    completed_date
  end
end
