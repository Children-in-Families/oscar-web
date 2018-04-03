class CaseNoteOverdueWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_id, short_name, clients)
    Organization.switch_to short_name
    user = User.find(user_id)
    CaseNoteOverdueMailer.overdue_case_notes_notify(clients, user, short_name).deliver_now
  end
end
