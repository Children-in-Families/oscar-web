class UserNotification
  def initialize(user)
    @user        = user
    @assessments = @user.assessment_either_overdue_or_due_today
  end

  def overdue_tasks
    Task.incomplete.overdue.of_user(@user)
  end

  def due_today_tasks
    Task.incomplete.today.of_user(@user)
  end

  def overdue_assessments_count
    @assessments[0]
  end

  def due_today_assessments_count
    @assessments[1]
  end

  def notification_count
    overdue_tasks.count + due_today_tasks.count + overdue_assessments_count + due_today_assessments_count
  end
end
