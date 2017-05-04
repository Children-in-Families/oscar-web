class UserReminder
  def initialize
  end

  def remind_case_workers
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      case_workers = User.where(roles: 'case worker')
      case_workers.each do |case_worker|
        CaseWorkerWorker.perform_async(case_worker.id, org.short_name)
      end
    end
  end
end