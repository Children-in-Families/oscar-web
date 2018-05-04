class CaseWorkerMailer < ApplicationMailer
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
    forms = client_forms(user)
    @overdue_forms = forms[:overdue_forms]
    @today_forms = forms[:today_forms]
    @upcoming_forms = forms[:upcoming_forms]
    @short_name = short_name
    if @overdue_forms.present? && @today_forms.present?
      mail(to: @user.email, subject: 'Overdue Forms and Due Today')
    elsif @overdue_forms.present?
      mail(to: @user.email, subject: 'Overdue Forms')
    else
      mail(to: @user.email, subject: 'Due Today Forms')
    end
  end


  def client_forms(user)
    overdue_forms = []
    today_forms = []
    upcoming_forms = []
    user.clients.active_accepted_status.each do |client|
      custom_fields = client.custom_fields.where.not(frequency: '')
      custom_fields.each do |custom_field|
        if client.next_custom_field_date(client, custom_field) < Date.today
          overdue_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        elsif client.next_custom_field_date(client, custom_field) == Date.today
          today_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        elsif client.next_custom_field_date(client, custom_field).between?(Date.tomorrow, 3.months.from_now)
          upcoming_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        end
      end

      client_active_enrollments = client.client_enrollments.active
      client_active_enrollments.each do |client_active_enrollment|
        trackings = client_active_enrollment.trackings.where.not(frequency: '')
        trackings.each do |tracking|
          last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
          if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
            overdue_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) == Date.today
            today_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking).between?(Date.tomorrow, 3.months.from_now)
            upcoming_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          end
        end
      end
    end
    { overdue_forms: overdue_forms.uniq, today_forms: today_forms.uniq, upcoming_forms: upcoming_forms.uniq }
  end
end
