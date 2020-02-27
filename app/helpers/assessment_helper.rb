module AssessmentHelper
  def assessment_edit_link(client, assessment)
    if assessment_editable?
      link_to(edit_client_assessment_path(assessment.client, assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if(false, edit_client_assessment_path(assessment.client, assessment)) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def assessment_destroy_link(client, assessment)
    if assessment_deleted?
      link_to(client_assessment_path(assessment.client, assessment), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if(false, client_assessment_path(assessment.client, assessment), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
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

  def assessment_deleted?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
  end

  def assessment_completed_date(assessment)
    if assessment.completed?
      completed_date = PaperTrail::Version.where(item_type: 'Assessment', item_id: assessment.id).where_object_changes(completed: true).last.created_at
    else
      completed_date = assessment.created_at
    end
    completed_date
  end

  def is_domain_definition(domain)
    domain.translate_score_1_definition.present? || domain.translate_score_2_definition.present? ||
    domain.translate_score_3_definition.present? || domain.translate_score_4_definition.present?
  end

  def score_definition(definition, score)
    definition.present? ? simple_format(definition) : score
  end

  def get_domains(cd, custom_assessment_setting_id=nil)
    if params[:custom] == 'true'
      cd.object.domain_group.custom_domain_identities(custom_assessment_setting_id)
    else
      cd.object.domain_group.default_domain_identities(custom_assessment_setting_id)
    end
  end

  def completed_initial_assessment?(type)
    return true if eval("@client.assessments.#{type}.count") == 0
    eval("@client.assessments.#{type}.order(created_at: :asc).first.completed")
  end

  def domain_translation_header(ad)
    if I18n.locale == :km && !ad.domain.custom_domain
      text = ad.domain.local_description[/<strong>.*<\/strong>/].gsub(/<strong>|<\/strong>/, '')
      domain_number = text[/[^\(.*]*/]
      domain_name   = text[/\(.*/]

      content_tag(:nil) do
        content_tag(:td, content_tag(:b, "#{domain_number}:"), class: "no-padding-bottom") + content_tag(:td, content_tag(:b, domain_name), class: "no-padding-bottom")
      end
    else
      content_tag(:td, content_tag(:b, "#{I18n.t('.domains.domain_list.domains')} #{ad.domain.name}:"), class: "no-padding-bottom") + content_tag(:td, content_tag(:b, ad.domain.identity), class: "no-padding-bottom")
    end
  end

  def assess_header_mapping(default=true)
    domains = default ? Domain.csi_domains.map{ |domain| ["domain_#{domain.id}", domain.name] } : Domain.custom_csi_domains.map{ |domain| ["domain_#{domain.id}", domain.name] }
    domain_ids, domain_headers = domains.map(&:first), domains.map(&:last)
    assessment_headers = [t('.client_id'), t('.client_name'), t('.assessment_number'), t('.assessment_date')]

    assessment_domain_headers = ['slug', 'name', 'assessment-number', 'date']
    classNames = ['client-id', 'client-name', 'ssessment-number text-center', 'assessment-date', 'assessment-score text-center']

    [*assessment_domain_headers, *domain_ids].zip(classNames, [*assessment_headers, *domain_headers]).map do |field_header, class_name, header_name|
      { title: header_name, data: field_header, className: class_name ? class_name : 'assessment-score text-center' }
    end
  end
end
