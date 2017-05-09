class ManagerMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def remind_of_client(clients, options = {})
    @clients = clients
    @manager = options[:manager]
    @day     = options[:day]
    mail(to: @manager, subject: 'Reminder [Clients Are About To Exit Emergency Care Program')
  end

  def case_worker_overdue_tasks_notify(manager, case_workers, org_name)
    @org_name     = org_name
    @manager      = manager
    @case_workers = case_workers
    return unless @case_workers.present?
    mail(to: @manager.email, subject: 'Case workers Overdue Task')
  end
end
