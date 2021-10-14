class CaseWorkerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_id, short_name)
    Organization.switch_to short_name
    case_worker = User.non_locked.notify_email.find_by(id: user_id)
    CaseWorkerMailer.overdue_tasks_notify(case_worker, short_name).deliver_now if case_worker
  end
end
