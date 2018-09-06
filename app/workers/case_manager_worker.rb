class CaseManagerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(manager_type, case_workers_ids, short_name)
    Organization.switch_to short_name
    if manager_type == 'EC'
      case_managers = User.ec_managers
    elsif manager_type == 'FC'
      case_managers = User.fc_managers
    elsif manager_type == 'KC'
      case_managers = User.kc_managers
    end

    case_managers.each do |manager|
      case_workers = User.where(id: case_workers_ids).sort_by{ |user| user.tasks.overdue_incomplete.exclude_exited_ngo_clients.size }.reverse
      ManagerMailer.case_worker_overdue_tasks_notify(manager, case_workers, short_name).deliver_now
    end
  end
end
