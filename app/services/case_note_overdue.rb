class CaseNoteOverdue
  def notify_user
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      setting = Setting.first
      max_case_note = setting.try(:max_case_note) || 30
      case_note_frequency = setting.try(:case_note_frequency) || 'day'
      case_note_period = max_case_note.send(case_note_frequency).ago
      User.all.each do |user|
        case_note_ids = CaseNote.no_case_note_in(case_note_period).ids
        client_ids = user.clients.joins(:case_notes).where(case_notes: { id: case_note_ids }).active_accepted_status.ids.uniq
        CaseNoteOverdueWorker.perform_async(client_ids, user.id, org.short_name) if client_ids.any?
      end
    end
  end
end
