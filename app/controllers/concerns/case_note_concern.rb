module CaseNoteConcern
  def assign_params_to_case_note_domain_groups_params(default_params)
    note = params.dig(:additional_fields, :note)
    attachments = params.dig(:case_note, :attachments) || []
    domain_group_ids = params.dig(:case_note, :domain_group_ids)&.reject(&:blank?) || []
    case_note_domain_groups = default_params[:case_note_domain_groups_attributes]

    selected_case_note_domain_groups = case_note_domain_groups.select{|key, value| domain_group_ids.include? value["domain_group_id"]}

    value = selected_case_note_domain_groups.values.first
    value['attachments'] = attachments if params[:action] == 'create' && value

    non_selected_case_note_domain_groups = case_note_domain_groups.select{|key, value| domain_group_ids.exclude? value["domain_group_id"]}
    non_selected_case_note_domain_groups.values.each do |value|
      next if params[:action] == 'create'
      cndg_id = value['id'].to_i
      cndg_attachments = CaseNoteDomainGroup.find(cndg_id).attachments
      cndg_attachments.each_with_index do |attachment, index|
        remove_attachment_at_index(index, cndg_id)
      end
    end
    default_params
  end

  def fetch_domain_group
    @domain_groups = []

    if params[:action].in?(['edit', 'update'])
      if @case_note.domain_groups.present?
        @domain_groups = @case_note.domain_groups
      else
        @domain_groups = DomainGroup.joins(:domains).where(id: @case_note.selected_domain_group_ids)
      end
    else
      if (@case_note.custom_assessment_setting_id.present?) || (params[:custom] == 'true' && @custom_assessment_setting&.id.present?)
        if @case_note.custom_assessment_setting_id.present?
          domain_group_ids = Domain.custom_csi_domains.where(custom_assessment_setting_id: @case_note.custom_assessment_setting_id).pluck(:domain_group_id).uniq
        else
          domain_group_ids = Domain.custom_csi_domains.where(custom_assessment_setting_id: @custom_assessment_setting&.id).pluck(:domain_group_id).uniq
        end
        @domain_groups = DomainGroup.where(id: domain_group_ids)
      else
        domain_group_ids = Domain.csi_domains.pluck(:domain_group_id).uniq
        @domain_groups = DomainGroup.where(id: domain_group_ids)
      end
    end

    case_note_domain_groups = CaseNoteDomainGroup.where(case_note: @case_note, domain_group: @domain_groups)
    @case_note_domain_group_note = case_note_domain_groups.where.not(note: '').map do |cndg|
      if !@case_note.custom
        group_name = cndg.domains(@case_note).map(&:identity).join(', ')
        "#{group_name}\n#{cndg.note}"
      else
        group_name = cndg.domain_group.custom_domain_identities(@custom_assessment_setting&.id || @case_note.custom_assessment_setting_id)
        "#{group_name}\n#{cndg.note}"
      end
    end.join("\n\n").html_safe
  end
end
