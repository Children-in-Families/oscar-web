class UserNotification
  def initialize(user)
    @user        = user
    @assessments = @user.assessment_either_overdue_or_due_today
  end

  def overdue_tasks_count
    # Task.overdue_incomplete.of_user(@user).size
    @user.tasks.overdue_incomplete.size
  end

  def any_overdue_tasks?
    overdue_tasks_count >= 1
  end

  def due_today_tasks_count
    # Task.today_incomplete.of_user(@user).size
    @user.tasks.today_incomplete.size
  end

  def any_due_today_tasks?
    due_today_tasks_count >= 1
  end

  def overdue_assessments_count
    @assessments[:overdue_count]
  end

  def any_overdue_assessments?
    overdue_assessments_count >= 1
  end

  def due_today_assessments_count
    @assessments[:due_today_count]
  end

  def any_due_today_assessments?
    due_today_assessments_count >= 1
  end

  def ec_notification(day)
    Client.active_ec.select { |client| client.active_day_care == day } if @user.admin? || @user.ec_manager?
  end

  def count
    if @user.admin? || @user.ec_manager?
      ec_notification(83).count + ec_notification(90).count + overdue_tasks_count + due_today_tasks_count + overdue_assessments_count + due_today_assessments_count
    else
      overdue_tasks_count + due_today_tasks_count + overdue_assessments_count + due_today_assessments_count
    end
  end
end
