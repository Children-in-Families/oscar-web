class FormNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_id, short_name)
    Organization.switch_to short_name
    case_worker = User.find(user_id)
    CaseWorkerMailer.forms_notifity(case_worker, short_name).deliver_now
  end
end
