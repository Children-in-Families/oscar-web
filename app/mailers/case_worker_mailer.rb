class CaseWorkerMailer < ApplicationMailer
  include CanCan::ModelAdditions::ClassMethods
  include ClientOverdueAndDueTodayForms

  def tasks_due_tomorrow_of(user)
    @user = user
    return if @user.disable? || @user.task_notify == false

    mail(to: @user.email, bcc: 'vibolteav@gmail.com', subject: 'Incomplete Tasks Due Tomorrow')
  end

  def overdue_tasks_notify(user, short_name)
    @user = user

    return if @user.nil? || @user&.disable? || @user&.task_notify == false

    @overdue_tasks = user.tasks.where(client_id: user_clients(user).active_accepted_status.ids).overdue_incomplete_ordered
    @short_name = short_name
    return unless @overdue_tasks.present?

    mail(to: @user.email, bcc: 'vibolteav@gmail.com', subject: 'Overdue Tasks', bcc: ENV['DEV2_EMAIL'])
  end

  def notify_upcoming_csi_weekly(client)
    @client = client
    recievers = client.users.non_locked.notify_email.pluck(:email)
    return if recievers.empty?

    default = @client.assessments.most_recents.first.try(:default)
    if default
      @name = Setting.first.default_assessment
      send_bulk_email(recievers, "Upcoming #{@name}")
    else
      CustomAssessmentSetting.only_enable_custom_assessment.find_each do |custom_assessment_setting|
        @name = custom_assessment_setting.custom_assessment_name
        send_bulk_email(recievers, "Upcoming #{@name}")
      end
    end
  end

  def notify_incomplete_daily_csi_assessments(client, custom_assessment_setting = nil)
    @client = client
    recievers = client.users.non_locked.notify_email.pluck(:email)
    return if recievers.empty?

    assessment = @client.assessments.most_recents.first
    default = assessment.try(:default)
    @overdue_date = assessment.created_at.to_date + 7
    if default
      @name = Setting.first.default_assessment
      send_bulk_email(recievers, "Incomplete #{@name}")
    else
      if custom_assessment_setting
        @name = custom_assessment_setting.custom_assessment_name
        send_bulk_email(recievers, "Incomplete #{@name}")
      end
    end
  end

  def forms_notifity(user, short_name)
    @user = user
    return if @user.nil? || @user&.disable? || @user&.task_notify == false

    if user.activated_at.present?
      clients = user_clients(user).where('clients.created_at > ?', user.activated_at).active_accepted_status
    else
      clients = user_clients(user).active_accepted_status
    end

    forms = overdue_and_due_today_forms(user, clients)
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

  private

  def send_bulk_email(recievers, subject)
    recievers.each_slice(50).to_a.each do |emails|
      next if emails.blank?

      mail(to: emails, subject: subject)
    end
  end

  def user_clients(user)
    user_ability = Ability.new(user)
    Client.accessible_by(user_ability)
  end
end
