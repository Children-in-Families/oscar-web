class CaseWorkerMailer < ApplicationMailer
  include ClientOverdueAndDueTodayForms

  def tasks_due_tomorrow_of(user)
    @user = user
    return if @user.disable?
    mail(to: @user.email, subject: 'Incomplete Tasks Due Tomorrow')
  end

  def overdue_tasks_notify(user, short_name)
    @user = user
    return if @user.disable?
    @overdue_tasks = user.tasks.where(client_id: user.clients.active_accepted_status.ids).overdue_incomplete_ordered
    @short_name = short_name
    return unless @overdue_tasks.present?
    mail(to: @user.email, subject: 'Overdue Tasks')
  end

  def notify_upcoming_csi_weekly(client)
    @client   = client
    recievers = client.users.non_locked.notify_email.pluck(:email)
    return if recievers.empty?
    dev_email = ENV['DEV_EMAIL']
    mail(to: recievers, subject: 'Upcoming CSI Assessment', bcc: dev_email)
  end

  def forms_notifity(user, short_name)
    @user = user
    forms = overdue_and_due_today_forms(user.clients.active_accepted_status)
    @overdue_forms = forms[:overdue_forms]
    @today_forms = forms[:today_forms]
    @upcoming_forms = forms[:upcoming_forms]
    @short_name = short_name
    if @overdue_forms.present? && @today_forms.present?
      mail(to: @user.email, subject: 'Overdue and due today forms')
    elsif @overdue_forms.present?
      mail(to: @user.email, subject: 'Overdue Forms')
    elsif @today_forms.present?
      mail(to: @user.email, subject: 'Due Today Forms')
    end
  end
end
