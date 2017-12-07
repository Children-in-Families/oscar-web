class AdminWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(empty, case_workers_ids, short_name)
    Organization.switch_to short_name
    case_workers = User.where(id: case_workers_ids).sort_by{ |user| user.tasks.overdue_incomplete.exclude_exited_ngo_clients.size }.reverse

    User.admins.each do |admin|
      next unless admin.task_notify
      AdminMailer.case_worker_overdue_tasks_notify(admin, case_workers, short_name).deliver_now
    end
  end
end
