class UserNotification
  def initialize(user)
    @user        = user
    @assessments = @user.assessment_either_overdue_or_due_today
  end

  def overdue_tasks_count
    Task.overdue_incomplete.of_user(@user).size
  end

  def any_overdue_tasks?
    overdue_tasks_count.positive?
  end

  def due_today_tasks_count
    Task.today_incomplete.of_user(@user).size
  end

  def any_due_today_tasks?
    due_today_tasks_count.positive?
  end

  def overdue_assessments_count
    @assessments[:overdue_count]
  end

  def any_overdue_assessments?
    overdue_assessments_count.positive?
  end

  def due_today_assessments_count
    @assessments[:due_today_count]
  end

  def any_due_today_assessments?
    due_today_assessments_count.positive?
  end

  def count
    overdue_tasks_count + due_today_tasks_count + overdue_assessments_count + due_today_assessments_count
  end
end
