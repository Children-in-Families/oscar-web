module CarePlanHelper
  def care_plan_edit_link(client, care_plan)
    if care_plan_editable?
      link_to(edit_client_care_plan_path(care_plan.client, care_plan)) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if(false, edit_client_care_plan_path(care_plan.client, care_plan)) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def care_plan_destroy_link(client, care_plan)
    if care_plan_deleted?
      link_to(client_care_plan_path(care_plan.client, care_plan), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if(false, client_care_plan_path(care_plan.client, care_plan), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def care_plan_editable?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.permission.assessments_editable
  end

  def care_plan_deleted?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
  end

end