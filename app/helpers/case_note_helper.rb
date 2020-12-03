module CaseNoteHelper
  def edit_link(client, case_note, cdg=nil)
    custom_assessment_setting_id = find_custom_assessment_setting_id(cdg, case_note) if cdg
    custom_name = CustomAssessmentSetting.find(custom_assessment_setting_id).try(:custom_assessment_name) if custom_assessment_setting_id
    if case_notes_editable? && policy(case_note).edit?
      link_to(edit_client_case_note_path(client, case_note, custom: case_note.custom, custom_name: custom_name), class: 'btn btn-primary') do
        fa_icon('pencil')
      end
    else
      link_to_if(false, edit_client_case_note_path(client, case_note)) do
        content_tag :div, class: 'btn btn-primary disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def destroy_link(client, case_note)
    if case_notes_deleted?
      link_to(client_case_note_path(client, case_note, custom: case_note.custom), method: 'delete', data: { confirm: t('.are_you_sure') }, class: 'btn btn-danger') do
        fa_icon('trash')
      end
    else
      link_to_if(false, client_case_note_path(client, case_note), method: 'delete', data: { confirm: t('.are_you_sure') }) do
        content_tag :div, class: 'btn btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def new_link
    if case_notes_editable? && policy(@client).create?
      link_to new_client_case_note_path(@client, custom: false) do
        @current_setting.default_assessment
      end
    else
      link_to_if false, '' do
        content_tag :a, class: 'disabled' do
          @current_setting.default_assessment
        end
      end
    end
  end

  def new_custom_link(custom_assessment_name)
    if case_notes_editable? && policy(@client).create?
      link_to new_client_case_note_path(@client, custom: true, custom_name: custom_assessment_name) do
        custom_assessment_name
      end
    else
      link_to_if false, '' do
        content_tag :a, class: 'disabled' do
          custom_assessment_name
        end
      end
    end
  end

  def fetch_domains(cd)
    if params[:custom] == 'true'
      custom_assessment_setting_id = @custom_assessment_setting&.id
      cd.object.domain_group.domains.custom_csi_domains.where(custom_assessment_setting_id: custom_assessment_setting_id)
    else
      cd.object.domain_group.domains.csi_domains
    end
  end

  def display_case_note_attendee(case_note)
    type = I18n.t("case_notes.form.type_options.#{case_note.interaction_type.downcase.split(' ').join('_').gsub(/3|other/, '3' => '', 'other' => 'other_option')}")
    case_note.interaction_type.present? ? "#{I18n.t('case_notes.index.present')} #{case_note.attendee} ( #{type} )" : "#{I18n.t('case_notes.index.present')} #{case_note.attendee}"
  end

  def case_notes_readable?
    return true if current_user.admin? || current_user.strategic_overviewer? || current_user.hotline_officer?
    current_user.permission&.case_notes_readable
  end

  def case_notes_editable?
    return true if current_user.admin? || current_user.hotline_officer?
    return false if current_user.strategic_overviewer?
    current_user.permission&.case_notes_editable
  end

  def tag_domain_group(case_note)
    domain_group_ids = selected_domain_groups(case_note)
    if domain_group_ids.present?
      domain_groups = DomainGroup.joins(:domains).where(id: domain_group_ids).map{ |dg| [dg.domain_name("#{case_note.custom}", case_note.custom_assessment_setting_id), dg.id] }
      options_for_select(domain_groups, domain_group_ids)
    else
      domain_group_ids = case_note.case_note_domain_groups.where("attachments != '{}' OR note != ''").pluck(:domain_group_id)
      domain_groups = case_note.domain_groups.map{ |dg| [dg.domain_name, dg.id] }
      options_for_select(domain_groups, domain_group_ids)
    end
  end

  def selected_domain_groups(case_note)
    case_note.selected_domain_group_ids.presence || []
  end

  def list_goals_and_tasks(cdg, case_note)
    list_goals = []
    ongoing_tasks = []
    today_tasks = []
    cdg.domains(case_note).each do |domain|
      tasks = case_note.client.tasks.where(domain_id: domain.id)
      ongoing_tasks << tasks.by_case_note_domain_group(cdg)
      today_tasks << case_note_the_latest_tasks(tasks.by_case_note_domain_group(cdg))
      assessment_domain = domain.assessment_domains.find_by(assessment_id: case_note.assessment_id)
      if assessment_domain.present? && assessment_domain.goal?
        list_goals << assessment_domain.goal
      end
    end

    [list_goals, ongoing_tasks, today_tasks]
  end

  def case_note_ongoing_tasks(tasks)
    ongoin_tasks = tasks.flatten.reject{ |task| task.completed || task.created_at.today? }
  end

  def case_note_the_latest_tasks(tasks)
    tasks.reject{ |task| !task.created_at.today? || task.completed }
  end

  def case_note_domain_without_assessment(domain_note, case_note)
    persisted_case_note = domain_note.object.domains(case_note).any?{|domain| case_note.client.tasks.where(domain_id: domain.id).by_case_note_domain_group(domain_note.object).present? } && case_note.persisted?
    domain_note_by_case_note = domain_note.object.domains(case_note)
    [persisted_case_note, domain_note_by_case_note]
  end

  def case_notes_deleted?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
  end

  def translate_domain_name(domains, case_note=nil)
    if case_note&.custom
      domains.map do |domain|
        [domain.id, domain.name]
      end
    else
      domains.map do |domain|
        [domain.id, t("domains.domain_names.#{domain.name.downcase.reverse}")]
      end
    end
  end

  def enable_default_assessment?
    setting = @current_setting
    setting && setting.enable_default_assessment
  end

  def not_using_assessment_tool?
    (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment))
  end

  def find_custom_assessment_setting_id(cdg, case_note)
    if case_note.custom_assessment_setting_id
      custom_assessment_setting_id = case_note.custom_assessment_setting_id
    else
      custom_assessment_setting_id = cdg.domains(case_note).pluck(:custom_assessment_setting_id).last
    end
  end

  def selected_domain_group(casenote_domai_group)
    @case_note.selected_domain_group_ids.compact.map(&:to_i).include?(casenote_domai_group.domain_group_id)
  end
end
