class AdminMailer < ApplicationMailer
  def remind_of_client(clients, options = {})
    @clients = clients
    @admin   = options[:admin]
    @day     = options[:day]
    mail(to: @admin, subject: 'Reminder [Clients Are About To Exit Emergency Care Program]')
  end

  def case_worker_overdue_tasks_notify(admin, case_workers, org_name)
    @org_name     = org_name
    @admin        = admin
    @case_workers = case_workers
    return unless @case_workers.present? && @admin.task_notify
    mail(to: @admin.email, subject: 'Case workers Overdue Task')
  end
end
