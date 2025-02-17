module CaseNoteConcern
  def case_note_params
    default_params = permit_case_note_params
    default_params = params.require(:case_note).permit(:meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id, :last_auto_save_at, attachments: [], case_note_domain_groups_attributes: [:id, :note, :domain_group_id, :task_ids, attachments: []]) if action_name == 'create'
    if params.dig(:case_note, :domain_group_ids)
      default_params = default_params.merge(selected_domain_group_ids: params.dig(:case_note, :domain_group_ids).reject(&:blank?))
      default_params = assign_params_to_case_note_domain_groups_params(default_params)
    end
    meeting_date = "#{default_params[:meeting_date]} #{Time.now.strftime('%T %z')}"
    default_params.merge(meeting_date: meeting_date)
  end

  def permit_case_note_params
    # tasks_attributes: [
    #   :id, :name, :completion_date, :completed, :completed_by_id, :_destroy,
    #   task_progress_notes_attributes: [:id, :progress_note, :task_id, :_destroy]
    # ]
    params.require(:case_note).permit(
      :meeting_date, :attendee, :interaction_type, :custom, :note, :custom_assessment_setting_id,
      case_note_domain_groups_attributes: [
        :id, :note, :domain_group_id, :task_ids
      ]
    )
  end

  def assign_params_to_case_note_domain_groups_params(default_params)
    # note = params.dig(:additional_fields, :note)
    attachments = params.dig(:case_note, :attachments) || []
    domain_group_ids = params.dig(:case_note, :domain_group_ids)&.reject(&:blank?) || []
    case_note_domain_groups = default_params[:case_note_domain_groups_attributes]

    selected_case_note_domain_groups = case_note_domain_groups.select { |_, value| domain_group_ids.include? value['domain_group_id'] }

    value = selected_case_note_domain_groups.values.first
    value['attachments'] = attachments if params[:action] == 'create' && value

    non_selected_case_note_domain_groups = case_note_domain_groups.select { |_, c_value| domain_group_ids.exclude? c_value['domain_group_id'] }
    non_selected_case_note_domain_groups.values.each do |c_value|
      next if params[:action] == 'create'

      # cndg_id = c_value['id'].to_i
      # cndg_attachments = CaseNoteDomainGroup.find(cndg_id).attachments
      # cndg_attachments.each_with_index do |_, index|
      #   remove_attachment_at_index(index, cndg_id)
      # end
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
      if @case_note.custom_assessment_setting_id.present? || (params[:custom] == 'true' && @custom_assessment_setting&.id.present?)
        if @case_note.custom_assessment_setting_id.present?
          domain_group_ids = Domain.custom_csi_domains.where(custom_assessment_setting_id: @case_note.custom_assessment_setting_id).pluck(:domain_group_id).uniq
        else
          domain_group_ids = Domain.custom_csi_domains.where(custom_assessment_setting_id: @custom_assessment_setting&.id).pluck(:domain_group_id).uniq
        end
      else
        domain_group_ids = Domain.csi_domains.pluck(:domain_group_id).uniq
      end
      @domain_groups = DomainGroup.where(id: domain_group_ids)
    end

    case_note_domain_groups = CaseNoteDomainGroup.where(case_note: @case_note, domain_group: @domain_groups)
    @case_note_domain_group_note = case_note_domain_groups.where.not(note: '').map do |cndg|
      if !@case_note.custom
        group_name = cndg.domains(@case_note).map(&:identity).join(', ')
      else
        group_name = cndg.domain_group.custom_domain_identities(@custom_assessment_setting&.id || @case_note.custom_assessment_setting_id)
      end
      "#{group_name}\n#{cndg.note}"
    end.join("\n\n").html_safe
  end

  def create_task_task_progress_notes
    (params[:case_note]['case_note_domain_groups_attributes'].try(:values) || []).each do |case_note_domain_groups_attributes|
      case_note_domain_groups_attr = case_note_domain_groups_attributes
      tasks_attributes = case_note_domain_groups_attr['tasks_attributes']
      tasks_attributes = tasks_attributes&.values || []
      tasks_attributes.each do |tasks_attr|
        task_id = tasks_attr['id']
        next unless task_id.present?

        task = Task.find(task_id)
        task_progress_notes_attributes = []
        next if tasks_attr['task_progress_notes_attributes'].nil?

        tasks_attr['task_progress_notes_attributes'].each do |_, v|
          next if v['task_id'].present?

          task_progress_notes_attributes << v.select { |h| h['progress_note'] }
        end
        task.task_progress_notes.create(task_progress_notes_attributes) if task_progress_notes_attributes.present?
      end
    end
  end

  def clean_duplicate_case_note_domain_groups
    return unless save_draft?

    domain_group_ids = params.dig(:case_note, :domain_group_ids).select(&:present?)

    if domain_group_ids.present?
      domain_groups = DomainGroup.where(id: domain_group_ids)
      domain_group_ids = domain_groups.map do |domain_group|
        domain_group.domains(@case_note).ids
      end.flatten
    end

    case_note_domain_groups = @case_note.case_note_domain_groups.where.not(domain_group_id: domain_group_ids)
    case_note_domain_groups = @case_note.case_note_domain_groups if domain_group_ids.blank?

    case_note_domain_groups.each do |case_note_domain_group|
      case_note_domain_group.tasks.destroy_all
      case_note_domain_group.destroy
    end

    id_mapping = {}
    @case_note.case_note_domain_groups.reload.each do |case_note_domain_group|
      if id_mapping[case_note_domain_group.domain_group_id].present?
        case_note_domain_group.tasks.destroy_all
        case_note_domain_group.destroy
      else
        id_mapping[case_note_domain_group.domain_group_id] = case_note_domain_group.id
      end
    end
  end

  def remove_attachment_at_index(case_note, index)
    remain_attachment = case_note.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove_images!)
    remain_attachment.empty? ? case_note.remove_attachments! : (case_note.attachments = remain_attachment)
    t('.fail_delete_attachment') unless case_note.save
  end

  def clean_case_note_domain_groups_attributes
    case_note_domain_groups_attributes = params.dig(:case_note, :case_note_domain_groups_attributes)

    return if case_note_domain_groups_attributes.blank?

    case_note_domain_groups_attributes.each do |index, case_note_domain_group_attributes|
      id = case_note_domain_group_attributes[:id]

      unless CaseNoteDomainGroup.exists?(id)
        case_note_domain_group_attributes.delete(:id)
        case_note_domain_groups_attributes[index] = case_note_domain_group_attributes
      end
    end

    params[:case_note][:case_note_domain_groups_attributes] = case_note_domain_groups_attributes
  end

  def set_case_note
    @case_note = CaseNote.unscoped do
      if params[:id] == 'draft'
        @client.find_or_create_draft_case_note(
          custom_assessment_setting_id: set_custom_assessment_setting&.id,
          custom: params[:custom]
        )
      else
        @client.case_notes.find(params[:id])
      end
    end
  end

  def set_custom_assessment_setting
    @custom_assessment_setting = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
  end
end
