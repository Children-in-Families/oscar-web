class ManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(manager_id, case_workers_ids, short_name)
    Organization.switch_to short_name
    manager = User.find(manager_id)
    case_workers = User.where(id: case_workers_ids)
    case_workers = case_workers.sort_by{ |user| user.tasks.length }.reverse
    ManagerMailer.case_worker_overdue_tasks_notify(manager, case_workers, short_name).deliver_now
  end
end
