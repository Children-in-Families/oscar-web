class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :notify_user

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
