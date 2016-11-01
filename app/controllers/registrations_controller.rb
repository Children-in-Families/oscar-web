class RegistrationsController < Devise::RegistrationsController

  before_action :notify_user, only: [:edit, :update]

  def new
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def create
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  private

  def notify_user
    notification                 = UserNotification.new(current_user)
    @overdue_tasks               = notification.overdue_tasks
    @due_today_tasks             = notification.due_today_tasks
    @overdue_assessments_count   = notification.overdue_assessments_count
    @due_today_assessments_count = notification.due_today_assessments_count
    @notification_count          = notification.notification_count
  end
end
