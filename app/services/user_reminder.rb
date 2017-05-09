class UserReminder
  def initialize
  end

  def remind
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      remind_case_workers(org)
      remind_manager_and_admin(org)
    end
  end


  private

  def remind_case_workers(org)
    case_workers = User.without_json_fields.joins(:tasks).merge(Task.overdue_incomplete).uniq
    case_workers.each do |case_worker|
      CaseWorkerWorker.perform_async(case_worker.id, org.short_name)
    end
  end

  def remind_manager_and_admin(org)
    case_workers_by_manager = User.without_json_fields.joins(:tasks).merge(Task.overdue_incomplete).uniq.group_by(&:manager_id)
    case_workers_by_manager.each do |manager_id, case_workers|
      case_workers_ids = case_workers.map(&:id)

      if manager_id.present?
        manager = User.find manager_id
        next unless manager.task_notify
        ManagerWorker.perform_async(manager_id, case_workers_ids, org.short_name)
      else
        AdminWorker.perform_async('', case_workers_ids, org.short_name)
      end
    end
  end
end
