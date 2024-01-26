class UserReminder
  def initialize
  end

  def remind
    Organization.oscar.without_shared.each do |org|
      Organization.switch_to org.short_name
      remind_case_worker_with_forms(org)
      remind_case_workers(org)
      remind_manager_and_admin(org)
      remind_managers_have_case_workers_overdue_tasks(org)
    end
  end

  private

  def remind_case_workers(org)
    case_workers = User.non_devs.non_locked.notify_email.without_json_fields.joins(:tasks).merge(Task.overdue_incomplete.exclude_exited_ngo_clients).uniq
    case_workers.each do |case_worker|
      CaseWorkerWorker.perform_async(case_worker.id, org.short_name)
    end
  end

  def remind_case_worker_with_forms(org)
    case_workers = User.non_devs.non_locked.notify_email.without_json_fields.joins(:clients).uniq
    case_workers.each do |case_worker|
      FormNotificationWorker.perform_async(case_worker.id, org.short_name)
    end
  end

  def remind_managers_have_case_workers_overdue_tasks(org)
    managers = User.managers.non_devs.non_locked.notify_email
    managers.each do |manager|
      case_worker_ids = User.non_devs.non_locked.notify_email.where('manager_ids && ARRAY[?]', manager.id).without_json_fields.joins(:clients).pluck(:id).uniq
      RemindManagerWorker.perform_async(manager.id, case_worker_ids, org.short_name)
    end
  end

  def remind_manager_and_admin(org)
    main_manager_id = 0
    case_workers_by_manager = User.non_devs.non_locked.without_json_fields.joins(:tasks).merge(Task.overdue_incomplete.exclude_exited_ngo_clients).uniq.group_by(&:manager_id)
    case_workers_by_manager.each do |manager_id, case_workers|
      if manager_id.present?
        begin
          manager = User.non_devs.find manager_id
        rescue Exception => e
          next
        end
        manager_ids = manager.manager_ids.present? ? manager.manager_ids : Array(manager.id)
        return if main_manager_id == manager_ids.last
        if manager_ids.any?
          user_ids = User.non_devs.where('manager_ids && ARRAY[?]', manager_ids).map(&:id)
          user_ids.push(manager_ids.last)
          user_ids.each do |case_workers_id|
            case_workers_ids = User.non_devs.joins(:tasks).merge(Task.overdue_incomplete.exclude_exited_ngo_clients).where('manager_ids && ARRAY[?]', case_workers_id).map(&:id).uniq
            next unless manager.task_notify

            ManagerWorker.perform_async(case_workers_id, case_workers_ids, org.short_name)
          end
        end
        main_manager_id = manager_ids.last
      else
        user_ids = case_workers.map do |user|
          user.id if user.tasks.count > 0 && user.clients.count > 0
        end
        AdminWorker.perform_async('', user_ids, org.short_name) if user_ids.present?
      end
    end
  end
end
