module DashboardHelper
  def checkbox_forms
    if @default_params
      'true'
    elsif @form_params
      'true'
    end
  end

  def family_tab?
    params[:tab] == 'family'
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
    tasks&.empty?
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
    client.next_assessment_date(@user.activated_at) < Date.today if client.next_assessment_date(@user.activated_at).present?
  end

  def duetoday_assessments_any?(client)
    client.next_assessment_date(@user.activated_at) == Date.today if client.next_assessment_date(@user.activated_at).present?
  end

  def upcoming_assessments_any?(client)
    client.next_assessment_date(@user.activated_at).between?(Date.tomorrow, 3.months.from_now) if client.next_assessment_date(@user.activated_at).present?
  end

  def overdue_custom_assessments_any?(client, custom_assessment_setting=nil)
    client.custom_next_assessment_date(@user.activated_at, custom_assessment_setting&.id) < Date.today if client.custom_next_assessment_date(@user.activated_at, custom_assessment_setting&.id).present?
  end

  def duetoday_custom_assessments_any?(client, custom_assessment=nil)
    client.custom_next_assessment_date(@user.activated_at, custom_assessment&.id) == Date.today if client.custom_next_assessment_date(@user.activated_at, custom_assessment&.id)
  end

  def upcoming_custom_assessments_any?(client)
    client.custom_next_assessment_date(@user.activated_at).between?(Date.tomorrow, 3.months.from_now) if client.custom_next_assessment_date(@user.activated_at).present?
  end

  # No longer used, moved to client.custom_next_assessment_date2
  def client_custom_next_assessment_date(client, activated_at=nil)
    return @client_custom_next_assessment_date if @client_custom_next_assessment_date.present?

    ids = client_custom_assessment_setting(client)

    @client_custom_next_assessment_date = CustomAssessmentSetting.only_enable_custom_assessment.where(id: ids).map do |custom_assessment|
      next if client.eligible_custom_csi?(custom_assessment)
      client.custom_next_assessment_date(activated_at, custom_assessment&.id)
    end.compact

    @client_custom_next_assessment_date
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
    skipped_forms = overdue_forms_empty?(forms) || client.users.cached_user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_overdue_assessments?(client)
    skipped_assessments = nil
    CustomAssessmentSetting.only_enable_custom_assessment.each do |custom_assessment|
      if @setting.enable_custom_assessment? && @setting.enable_default_assessment
        skipped_assessments = (!overdue_assessments_any?(client) && !overdue_custom_assessments_any?(client)) || client.cached_user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?(custom_assessment))
      elsif @setting.enable_default_assessment
        skipped_assessments = !overdue_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_default_csi?
      else
        skipped_assessments = !overdue_custom_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_custom_csi?(custom_assessment)
      end
      skipped_assessments = client.cached_user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?(custom_assessment))
    end

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
    skipped_forms = duetoday_forms_empty?(forms) || client.cached_user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_duetoday_assessments?(client)
    return @skipped_duetoday_assessments if @skipped_duetoday_assessments.present?

    CustomAssessmentSetting.all.each do |custom_assessment|
      if @setting.enable_custom_assessment? && @setting.enable_default_assessment
        @skipped_duetoday_assessments = (!duetoday_assessments_any?(client) && !duetoday_custom_assessments_any?(client)) || client.cached_user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?(custom_assessment))
      elsif @setting.enable_default_assessment
        @skipped_duetoday_assessments = !duetoday_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_default_csi?
      else
        @skipped_duetoday_assessments = !duetoday_custom_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_custom_csi?(custom_assessment)
      end
    end

    @skipped_duetoday_assessments = !@assessment_params unless @skipped_duetoday_assessments
    @skipped_duetoday_assessments
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
    skipped_forms = upcoming_forms_empty?(forms) || client.cached_user_ids.exclude?(@user.id)
    skipped_forms ? true : false
  end

  def skipped_upcoming_assessments?(client)
    return @skipped_upcoming_assessments if @skipped_upcoming_assessments.present?

    CustomAssessmentSetting.find_each do |custom_assessment|
      if @setting.enable_custom_assessment? && @setting.enable_default_assessment
        @skipped_upcoming_assessments = (!upcoming_assessments_any?(client) && !upcoming_custom_assessments_any?(client)) || client.cached_user_ids.exclude?(@user.id) || (!client.eligible_default_csi? && !client.eligible_custom_csi?(custom_assessment))
      elsif @setting.enable_default_assessment
        @skipped_upcoming_assessments = !upcoming_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_default_csi?
      else
        @skipped_upcoming_assessments = !upcoming_custom_assessments_any?(client) || client.cached_user_ids.exclude?(@user.id) || !client.eligible_custom_csi?(custom_assessment)
      end
    end

    @skipped_upcoming_assessments = !@assessment_params unless @skipped_upcoming_assessments
    @skipped_upcoming_assessments
  end

  def just_sign_in?
    current_user.current_sign_in_at.to_time.to_i >= (Time.now - 3.second).to_i
  end

  def client_custom_assessment_setting(client)
    custom_assessment_setting_ids = client.custom_assessment_domains.map(&:custom_assessment_setting_id).flatten.uniq
  end
end
