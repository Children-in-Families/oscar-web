module DashboardHelper
  def checkbox_forms
    if @default_params
      'true'
    elsif @form_params
      'true'
    end
  end

  def checkbox_tasks
    if @default_params
      'true'
    elsif @task_params
      'true'
    end
  end

  def checkbox_assessments
    if @default_params
      'true'
    elsif @assessment_params
      'true'
    end
  end

  def tasks_empty?(tasks)
    tasks.empty?
  end

  def overdue_forms_empty?(forms)
    forms[:overdue_forms].empty? && forms[:overdue_trackings].empty?
  end

  def duetoday_forms_empty?(forms)
    forms[:today_forms].empty? && forms[:today_trackings].empty?
  end

  def upcoming_forms_empty?(forms)
    forms[:upcoming_forms].empty? && forms[:upcoming_trackings].empty?
  end

  def overdue_assessments_any?(client)
    client.next_assessment_date < Date.today
  end

  def duetoday_assessments_any?(client)
    client.next_assessment_date == Date.today
  end

  def upcoming_assessments_any?(client)
    client.next_assessment_date.between?(Date.tomorrow, 3.months.from_now)
  end

  def overdue_custom_assessments_any?(client)
    client.custom_next_assessment_date < Date.today
  end

  def duetoday_custom_assessments_any?(client)
    client.custom_next_assessment_date == Date.today
  end

  def upcoming_custom_assessments_any?(client)
    client.custom_next_assessment_date.between?(Date.tomorrow, 3.months.from_now)
  end

  def skipped_overdue_tasks?(tasks)
    skipped_tasks = tasks_empty?(tasks)
    if skipped_tasks
      true
    elsif @task_params
      false
    else
      true
    end
  end

  def skipped_overdue_forms?(forms, client)
    skipped_forms = overdue_forms_empty?(forms) || client.user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_overdue_assessments?(client)
    if @setting.enable_custom_assessment && @setting.enable_default_assessment
      skipped_assessments = (!overdue_assessments_any?(client) && !overdue_custom_assessments_any?(client)) || client.user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?)
    elsif @setting.enable_default_assessment
      skipped_assessments = !overdue_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_default_csi?
    else
      skipped_assessments = !overdue_custom_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_custom_csi?
    end
    skipped_assessments = !overdue_assessments_any?(client) || client.user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?)
    if skipped_assessments
      true
    elsif @assessment_params
      false
    else
      true
    end
  end

  def skipped_duetoday_tasks?(tasks)
    skipped_tasks = tasks_empty?(tasks)
    if skipped_tasks
      true
    elsif @task_params
      false
    else
      true
    end
  end

  def skipped_duetoday_forms?(forms, client)
    skipped_forms = duetoday_forms_empty?(forms) || client.user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_duetoday_assessments?(client)
    if @setting.enable_custom_assessment && @setting.enable_default_assessment
      skipped_assessments = (!duetoday_assessments_any?(client) && !duetoday_custom_assessments_any?(client)) || client.user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?)
    elsif @setting.enable_default_assessment
      skipped_assessments = !duetoday_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_default_csi?
    else
      skipped_assessments = !duetoday_custom_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_custom_csi?
    end
    if skipped_assessments
      true
    elsif @assessment_params
      false
    else
      true
    end
  end

  def skipped_upcoming_tasks?(tasks)
    skipped_tasks = tasks_empty?(tasks)
    if skipped_tasks
      true
    elsif @task_params
      false
    else
      true
    end
  end

  def skipped_upcoming_forms?(forms, client)
    skipped_forms = upcoming_forms_empty?(forms) || client.user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_upcoming_assessments?(client)
    if @setting.enable_custom_assessment && @setting.enable_default_assessment
      skipped_assessments = (!upcoming_assessments_any?(client) && !upcoming_custom_assessments_any?(client)) || client.user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?)
    elsif @setting.enable_default_assessment
      skipped_assessments = !upcoming_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_default_csi?
    else
      skipped_assessments = !upcoming_custom_assessments_any?(client) || client.user_ids.exclude?(@user.id) || !client.eligible_custom_csi?
    end
    if skipped_assessments
      true
    elsif @assessment_params
      false
    else
      true
    end
  end
end
