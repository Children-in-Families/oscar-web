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
    if @user.admin? || @user.ec_manager?
      clients = Client.active_ec.select{ |client| client.active_day_care == day }
    end
  end

  def count
    count_notification = 0
    if @user.admin? || @user.ec_manager?
      (83..90).each do |item|
        count_notification += 1 if ec_notification(item).present?
      end
      count_notification += 1 if overdue_tasks_count >= 1
      count_notification += 1 if due_today_tasks_count >= 1
      count_notification += 1 if overdue_assessments_count >= 1
      count_notification += 1 if due_today_assessments_count >= 1
    else
      count_notification += 1 if overdue_tasks_count >= 1
      count_notification += 1 if due_today_tasks_count >= 1
      count_notification += 1 if overdue_assessments_count >= 1
      count_notification += 1 if due_today_assessments_count >= 1
    end
  end
end
