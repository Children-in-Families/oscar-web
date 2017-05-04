class CaseWorkerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_id, short_name)
    Organization.switch_to short_name
    case_worker = User.find(user_id)
    CaseWorkerMailer.overdue_tasks_notify(case_worker, short_name).deliver_now
  end
end
