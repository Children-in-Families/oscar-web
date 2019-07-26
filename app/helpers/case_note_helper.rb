module CaseNoteHelper
  def edit_link(client, case_note)
    if case_notes_editable? && policy(case_note).edit?
      link_to(edit_client_case_note_path(client, case_note, custom: case_note.custom), class: 'btn btn-primary') do
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

  def new_custom_link
    if case_notes_editable? && policy(@client).create?
      link_to new_client_case_note_path(@client, custom: true) do
        @current_setting.custom_assessment
      end
    else
      link_to_if false, '' do
        content_tag :a, class: 'disabled' do
          @current_setting.custom_assessment
        end
      end
    end
  end

  def fetch_domains(cd)
    if params[:custom] == 'true'
      cd.object.domain_group.domains.custom_csi_domains
    else
      cd.object.domain_group.domains.csi_domains
    end
  end

  def display_case_note_attendee(case_note)
    type = I18n.t("case_notes.form.type_options.#{case_note.interaction_type.downcase.split(' ').join('_').gsub(/3|other/, '3' => '', 'other' => 'other_option')}")
    case_note.interaction_type.present? ? "#{I18n.t('case_notes.index.present')} #{case_note.attendee} ( #{type} )" : "#{I18n.t('case_notes.index.present')} #{case_note.attendee}"
  end

  def case_notes_readable?
    return true if current_user.admin? || current_user.strategic_overviewer?
    current_user.permission.case_notes_readable
  end

  def case_notes_editable?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.permission.case_notes_editable
  end

  def translate_domain_name(domains)
    domains.map do |domain|
      [domain.id, t("domains.domain_names.#{domain.name.downcase.reverse}")]
    end
  end

  def tag_domain_group(case_note)
    domain_group_ids = case_note.case_note_domain_groups.where("attachments != '{}' OR note != ''").pluck(:domain_group_id)
    domain_groups = case_note.domain_groups.map{ |dg| [dg.domain_name("#{case_note.custom}"), dg.id] }
    options_for_select(domain_groups, domain_group_ids)
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
    tasks.reject{ |task| !task.created_at.today? }
  end
end
