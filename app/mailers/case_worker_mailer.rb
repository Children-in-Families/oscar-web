class CaseWorkerMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def tasks_due_tomorrow_of(user)
    @user = user
    mail(to: @user.email, subject: 'Incomplete Tasks Due Tomorrow')
  end

  def overdue_tasks_notify(user, short_name)
    @user = user
    @overdue_tasks = user.tasks.overdue_incomplete_ordered
    @short_name = short_name
    return unless @overdue_tasks.present?
    mail(to: @user.email, subject: 'Overdue Tasks')
  end
end
