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

  def care_plan_status(care_plan)
    care_plan.completed? ? 'Completed' : 'Incompleted'
  end

  def care_plan_label(care_plan)
    care_plan.completed? ? 'label label-primary' : 'label label-danger'
  end

  def care_plan_completed_date
    grid_object.column(:care_plan_completed_date, header: -> { I18n.t('datagrid.columns.clients.care_plan_completed_date') }) do |object|
      date_filter(object.care_plans, 'care_plan_completed_date').map{ |care_plan| date_format(care_plan.created_at) }.join(", ")
    end
  end

  def care_plan_count
    grid_object.column(:care_plan_count, header: -> { I18n.t('datagrid.columns.clients.care_plan_count') }) do |object|
      date_filter(object.care_plans, 'care_plan_completed_date').count
    end
  end

  def grid_object
    @client_grid || @family_grid
  end
end
