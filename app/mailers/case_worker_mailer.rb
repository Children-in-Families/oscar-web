class CaseWorkerMailer < ApplicationMailer
  def tasks_due_tomorrow_of(user)
    @user = user
    mail(to: @user.email, subject: 'Incomplete Tasks Due Tomorrow')
  end

  def overdue_tasks_notify(user, short_name)
    @user = user
    @overdue_tasks = user.tasks.exclude_exited_ngo_clients.where(client_id: user.clients.ids).overdue_incomplete_ordered
    @short_name = short_name
    return unless @overdue_tasks.present?
    mail(to: @user.email, subject: 'Overdue Tasks')
  end

  def notify_upcoming_csi_weekly(client)
    @client   = client
    recievers = client.users.pluck(:email)
    dev_email = ENV['DEV_EMAIL']
    mail(to: recievers, subject: 'Upcoming CSI Assessment', bcc: dev_email)
  end
end
