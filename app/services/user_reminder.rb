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

      if manager_id.present?
        case_workers_ids = case_workers.map(&:id)
        manager = User.find manager_id
        next unless manager.task_notify
        ManagerWorker.perform_async(manager_id, case_workers_ids, org.short_name)
      else
        tasks           = case_workers.map(&:tasks).flatten
        client_ids      = tasks.map(&:client_id).uniq

        client_of     = clients_by_manager(client_ids)

        CaseManagerWorker.perform_async('FC', client_of[:fc], org.short_name) if client_of[:fc].present?
        CaseManagerWorker.perform_async('KC', client_of[:kc], org.short_name) if client_of[:kc].present?
        CaseManagerWorker.perform_async('EC', client_of[:ec], org.short_name) if client_of[:ec].present?

        AdminWorker.perform_async('', admin_case_workers(client_ids), org.short_name) if admin_case_workers(client_ids).present?
      end
    end
  end

  def clients_by_manager(client_ids)
    {
      ec: Client.active_ec.where(id: client_ids).pluck(:user_id).uniq,
      fc: Client.active_fc.where(id: client_ids).pluck(:user_id).uniq,
      kc: Client.active_kc.where(id: client_ids).pluck(:user_id).uniq
    }
  end

  def admin_case_workers(client_ids)
    Client.where.not(status: ['Active EC', 'Active FC', 'Active KC']).where(id: client_ids).pluck(:user_id).uniq
  end
end
