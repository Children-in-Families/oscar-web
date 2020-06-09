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
end
