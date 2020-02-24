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

  def case_notes_deleted?
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
  end

  def translate_domain_name(domains)
    domains.map do |domain|
      [domain.id, t("domains.domain_names.#{domain.name.downcase.reverse}")]
    end
  end

  def enable_default_assessment?
    setting = @current_setting
    setting && setting.enable_default_assessment
  end

  def not_using_assessment_tool?
    (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment))
  end
end
