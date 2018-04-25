namespace :case_note_overdue do
  desc 'Notify user has overdue case note'
  task notify: :environment do
    case_note_overdue = CaseNoteOverdue.new
    case_note_overdue.notify_user
  end
end
