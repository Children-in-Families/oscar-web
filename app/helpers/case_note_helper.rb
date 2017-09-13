module CaseNoteHelper
  def edit_link(client, case_note)
    if policy(case_note).edit?
      link_to(edit_client_case_note_path(client, case_note), class: 'btn btn-primary') do
        fa_icon('pencil')
      end
    end
  end

  def display_case_note_attendee(case_note)
    case_note.interaction_type.present? ? "#{t('.present')} #{case_note.attendee} ( #{case_note.interaction_type} )" : "#{t('.present')} #{case_note.attendee}"
  end
end
