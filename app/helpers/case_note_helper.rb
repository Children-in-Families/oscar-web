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
    type = I18n.t("case_notes.form.type_options.#{case_note.interaction_type.downcase.split(' ').join('_').gsub('3', '')}")
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

  def tag_domain_group(case_note)
    domain_group_ids = case_note.case_note_domain_groups.where("attachments != '{}' OR note != ''").pluck(:domain_group_id)
    domain_groups = case_note.domain_groups.map{ |dg| [dg.domain_name, dg.id] }
    options_for_select(domain_groups, domain_group_ids)
  end

  def case_note_ongoing_tasks(case_note, cdg)
    domains = cdg.domains(case_note).select(:id)
    tasks   = case_note.client.tasks.upcoming.where(domain_id: domains.pluck(:id))
  end

  def case_note_today_tasks(case_note, cdg)
    domains = cdg.domains(case_note).select(:id)
    tasks   = case_note.client.tasks.today.where(domain_id: domains.pluck(:id))
  end
end
