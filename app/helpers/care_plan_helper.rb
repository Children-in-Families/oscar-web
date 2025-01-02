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

    false if current_user.strategic_overviewer?
  end

  def care_plan_status(care_plan)
    care_plan.completed? ? 'Completed' : 'Incompleted'
  end

  def care_plan_label(care_plan)
    care_plan.completed? ? 'label label-primary' : 'label label-danger'
  end

  def care_plan_date
    grid_object.column(:care_plan_date, header: -> { I18n.t('care_plans.care_plan_date') }) do |object|
      date_filter(object.care_plans, 'care_plan_date').map { |care_plan| date_format(care_plan.care_plan_date) }.join(', ')
    end
  end

  def care_plan_completed_date
    grid_object.column(:care_plan_completed_date, header: -> { I18n.t('datagrid.columns.clients.care_plan_completed_date') }) do |object|
      date_filter(object.care_plans, 'care_plan_completed_date').map { |care_plan| date_format(care_plan.created_at) }.join(', ')
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

  def list_case_conference_domain_for_care_plan(assessment, ad)
    return [] if assessment.case_conference.blank?

    assessment.case_conference.case_conference_domains.find_by(domain_id: ad.object.domain_id).try(:case_conference_addressed_issues) || []
  end

  def display_domain_definition_description(domain, domain_definition)
    description = I18n.locale == :km ? domain.local_description : domain.description

    domain_definition_hash = description.scan(/\<strong\>.*\<\/strong\>/).last(4).zip(description.gsub(/\r\n\n/, '').scan(/\<ul\>.*\<\/ul\>/)).to_h
    domain_definition_hash.present? && domain_definition_hash["<strong>#{domain_definition}</strong>"]
  end
end
