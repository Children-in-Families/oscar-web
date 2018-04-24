class CaseNoteOverdueWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(client_ids, user_id, short_name)
    Organization.switch_to short_name
    user = User.find(user_id)
    CaseNoteOverdueMailer.overdue_case_notes_notify(client_ids, user, short_name).deliver_now
  end
end
