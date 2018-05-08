class SharedClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  # def perform(empty, case_workers_ids, short_name)
  #   Organization.switch_to short_name
  #   case_workers = User.where(id: case_workers_ids).sort_by{ |user| user.tasks.overdue_incomplete.exclude_exited_ngo_clients.size }.reverse
  #
  #   User.admins.each do |admin|
  #     next unless admin.task_notify
  #     AdminMailer.case_worker_overdue_tasks_notify(admin, case_workers, short_name).deliver_now
  #   end
  # end

  def perform(shared_client_id, origin_ngo)
    # shared_client = SharedClient.find_by(id: shared_client_id)
    # binding.pry
    # Organization.switch_to destination_ngo
    # admin_emails = User.admins.pluck(:email)
    SharedClientMailer.notify_of_shared_client(shared_client_id, origin_ngo).deliver_now
  end
end
