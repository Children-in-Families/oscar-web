module CaseNoteHelper
  def edit_link(client, case_note)
    if case_notes_editable? && policy(case_note).edit?
      link_to(edit_client_case_note_path(client, case_note), class: 'btn btn-primary') do
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
      link_to new_client_case_note_path(@client) do
        content_tag :div, class: 'btn btn-primary button' do
          t('.new_case_note')
        end
      end
    else
      link_to_if false, new_client_case_note_path(@client) do
        content_tag :div, class: 'btn btn-primary button disabled' do
          t('.new_case_note')
        end
      end
    end
  end

  def display_case_note_attendee(case_note)
    case_note.interaction_type.present? ? "#{t('.present')} #{case_note.attendee} ( #{case_note.interaction_type} )" : "#{t('.present')} #{case_note.attendee}"
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
end
