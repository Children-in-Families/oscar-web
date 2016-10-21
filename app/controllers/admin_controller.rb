class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :user_notify

  private
  def user_notify
    @overdue_tasks   = Task.incomplete.overdue.of_user(current_user)
    @due_today_tasks = Task.incomplete.today.of_user(current_user)
    assessments      = current_user.assessment_either_overdue_or_due_today
    @overdue_assessments_count   = assessments[0]
    @due_today_assessments_count = assessments[1]
    @notification_count = (@overdue_tasks.count + @due_today_tasks.count + @overdue_assessments_count + @due_today_assessments_count)
  end
end
