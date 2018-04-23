class UserNotification

  attr_reader :all_count

  def initialize(user, clients)
    @user                                            = user
    @clients                                         = clients
    @assessments                                     = @user.assessment_either_overdue_or_due_today
    @client_custom_field                             = @user.client_custom_field_frequency_overdue_or_due_today
    @user_custom_field                               = @user.user_custom_field_frequency_overdue_or_due_today if @user.admin? || @user.manager?
    @partner_custom_field                            = @user.partner_custom_field_frequency_overdue_or_due_today
    @family_custom_field                             = @user.family_custom_field_frequency_overdue_or_due_today
    @client_enrollment_tracking_user_notification    = @user.client_enrollment_tracking_overdue_or_due_today
    @case_notes_overdue_and_due_today                = @user.case_note_overdue_and_due_today
    @all_count                                       = count
  end

  def upcoming_csi_assessments
    client_ids = []
    csi_count = 0
    clients = @user.clients.active_accepted_status
    clients.each do |client|
      next if client.assessments.empty?
      repeat_notifications = client.repeat_notifications_schedule

      if(repeat_notifications.include?(Date.today))
        client_ids << client.id
        csi_count += 1
      end
    end
    clients = clients.where(id: client_ids)
    { csi_count: csi_count, clients: clients }
  end

  def any_upcoming_csi_assessments?
    upcoming_csi_assessments[:csi_count] >= 1
  end

  def overdue_tasks_count
    @user.tasks.overdue_incomplete.exclude_exited_ngo_clients.where(client_id: @user.clients.ids).size
  end

  def review_program_streams
    client_wrong_program_rules = []
    program_streams_by_user.each do |program_stream|
      rules = program_stream.rules
      client_ids = program_stream.client_enrollments.active.pluck(:client_id)
      clients = Client.active_accepted_status.where(id: client_ids)
      clients_after_filter = AdvancedSearches::ClientAdvancedSearch.new(rules, clients).filter
      if clients_after_filter.any?
        clients_change = clients.where.not(id: clients_after_filter.ids).ids
        client_wrong_program_rules << [program_stream, clients_change] if clients_change.any?
      else
        client_wrong_program_rules << [program_stream, clients.ids] if clients.any?
      end
    end
    client_wrong_program_rules
  end

  def any_overdue_tasks?
    overdue_tasks_count >= 1
  end

  def due_today_tasks_count
    @user.tasks.today_incomplete.exclude_exited_ngo_clients.where(client_id: @user.clients.ids).size
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
      Client.exit_in_week(day)
    end
  end

  def any_client_custom_field_frequency_overdue?
    client_custom_field_frequency_overdue_count >= 1
  end

  def any_client_custom_field_frequency_due_today?
    client_custom_field_frequency_due_today_count >= 1
  end

  def client_custom_field_frequency_due_today_count
    @client_custom_field[:entity_due_today].count
  end

  def client_custom_field_frequency_overdue_count
    @client_custom_field[:entity_overdue].count
  end

  def client_custom_field_frequency_due_today
    @client_custom_field[:entity_due_today]
  end

  def client_custom_field_frequency_overdue
    @client_custom_field[:entity_overdue]
  end

  def any_user_custom_field_frequency_overdue?
    user_custom_field_frequency_overdue_count >= 1
  end

  def any_user_custom_field_frequency_due_today?
    user_custom_field_frequency_due_today_count >= 1
  end

  def user_custom_field_frequency_due_today_count
    @user_custom_field[:entity_due_today].count
  end

  def user_custom_field_frequency_overdue_count
    @user_custom_field[:entity_overdue].count
  end

  def user_custom_field_frequency_due_today
    @user_custom_field[:entity_due_today]
  end

  def user_custom_field_frequency_overdue
    @user_custom_field[:entity_overdue]
  end

  def any_partner_custom_field_frequency_overdue?
    partner_custom_field_frequency_overdue_count >= 1
  end

  def any_partner_custom_field_frequency_due_today?
    partner_custom_field_frequency_due_today_count >= 1
  end

  def partner_custom_field_frequency_due_today_count
    @partner_custom_field[:entity_due_today].count
  end

  def partner_custom_field_frequency_overdue_count
    @partner_custom_field[:entity_overdue].count
  end

  def partner_custom_field_frequency_due_today
    @partner_custom_field[:entity_due_today]
  end

  def partner_custom_field_frequency_overdue
    @partner_custom_field[:entity_overdue]
  end

  def any_family_custom_field_frequency_overdue?
    family_custom_field_frequency_overdue_count >= 1
  end

  def any_family_custom_field_frequency_due_today?
    family_custom_field_frequency_due_today_count >= 1
  end

  def family_custom_field_frequency_due_today_count
    @family_custom_field[:entity_due_today].count
  end

  def family_custom_field_frequency_overdue_count
    @family_custom_field[:entity_overdue].count
  end

  def family_custom_field_frequency_due_today
    @family_custom_field[:entity_due_today]
  end

  def family_custom_field_frequency_overdue
    @family_custom_field[:entity_overdue]
  end

  def client_enrollment_tracking_frequency_due_today_count
    @client_enrollment_tracking_user_notification[:clients_due_today].count
  end

  def client_enrollment_tracking_frequency_overdue_count
    @client_enrollment_tracking_user_notification[:clients_overdue].count
  end

  def any_client_enrollment_tracking_frequency_due_today?
    client_enrollment_tracking_frequency_due_today_count >= 1
  end

  def any_client_enrollment_tracking_frequency_overdue?
    client_enrollment_tracking_frequency_overdue_count >= 1
  end

  def client_enrollment_tracking_frequency_due_today
    @client_enrollment_tracking_user_notification[:clients_due_today]
  end

  def client_enrollment_tracking_frequency_overdue
    @client_enrollment_tracking_user_notification[:clients_overdue]
  end

  def any_client_case_note_overdue?
    client_case_note_overdue_count >= 1
  end

  def client_case_note_overdue_count
    client_case_note_overdue.count
  end

  def client_case_note_overdue
    @case_notes_overdue_and_due_today[:client_overdue]
  end

  def any_client_case_note_due_today?
    client_case_note_due_today_count >= 1
  end

  def client_case_note_due_today_count
    client_case_note_due_today.count
  end

  def client_case_note_due_today
    @case_notes_overdue_and_due_today[:client_due_today]
  end

  def count
    count_notification = 0

    if @user.admin? || @user.ec_manager?
      (83..90).each do |item|
        count_notification += 1 if ec_notification(item).present?
      end
    end
    if @user.admin? || @user.manager?
      count_notification += 1 if any_user_custom_field_frequency_overdue?
      count_notification += 1 if any_user_custom_field_frequency_due_today?
    end
    if @user.admin? || @user.any_case_manager?
      count_notification += 1 if any_partner_custom_field_frequency_overdue?
      count_notification += 1 if any_partner_custom_field_frequency_due_today?
      count_notification += 1 if any_family_custom_field_frequency_overdue?
      count_notification += 1 if any_family_custom_field_frequency_due_today?
    end
    unless @user.strategic_overviewer?
      count_notification += 1 if any_client_custom_field_frequency_overdue?
      count_notification += 1 if any_client_custom_field_frequency_due_today?
      count_notification += 1 if any_overdue_tasks?
      count_notification += 1 if any_due_today_tasks?
      count_notification += 1 if any_overdue_assessments? && enable_assessment_setting?
      count_notification += 1 if any_due_today_assessments? && enable_assessment_setting?
      count_notification += 1 if any_client_enrollment_tracking_frequency_due_today?
      count_notification += 1 if any_client_enrollment_tracking_frequency_overdue?
      count_notification += 1 if any_upcoming_csi_assessments? && enable_assessment_setting?
      count_notification += 1 if any_client_case_note_overdue?
      count_notification += 1 if any_client_case_note_due_today?
    end
    count_notification += review_program_streams.size
  end

  private

  def program_streams_by_user
    ProgramStream.complete.includes(:client_enrollments).where.not(client_enrollments: { id: nil, status: 'Exited' }, program_streams: { rules: "{}"}).where(client_enrollments: { client_id: @clients.ids })
  end

  def enable_assessment_setting?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end
end
