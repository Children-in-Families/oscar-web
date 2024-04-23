class NotificationsController < AdminController
  include NotificationConcern

  def index
    entity_custom_field = params[:entity_custom_field]
    client_enrollment_tracking = params[:client_enrollment_tracking]
    upcoming_assessment = params[:assessment]
    case_note_overdue = params[:client_case_note_overdue_and_due_today]
    if entity_custom_field.present?
      entity_custom_field_notification(entity_custom_field)
      if entity_custom_field == 'client_due_today' || entity_custom_field == 'user_due_today' || entity_custom_field == 'partner_due_today' || entity_custom_field == 'family_due_today'
        render 'custom_field_due_today'
      else
        render 'custom_field_overdue'
      end
    elsif client_enrollment_tracking.present?
      client_enrollment_tracking_notification(client_enrollment_tracking)
      if client_enrollment_tracking == 'client_enrollment_tracking_due_today'
        render 'client_enrollment_tracking_due_today'
      else
        render 'client_enrollment_tracking_overdue'
      end
    elsif upcoming_assessment.presence == 'upcoming'
      if params[:default] == 'true'
        @upcoming_csi_clients_notification = @notification.client_upcoming_csi_assessments.order(:given_name, :family_name)
      else
        @upcoming_csi_clients_notification = @notification.client_upcoming_custom_csi_assessments.order(:given_name, :family_name)
      end
      render 'upcoming_assessment'
    elsif case_note_overdue.present?
      if case_note_overdue == 'due_today'
        @clients = @notification.client_case_note_due_today.sort_by { |p| p.send('name').to_s.downcase }
        render 'case_note_due_today'
      else
        @clients = @notification.client_case_note_overdue.sort_by { |p| p.send('name').to_s.downcase }
        render 'case_note_overdue'
      end
    end
  end

  def program_stream_notify
    @program_stream = ProgramStream.find(params[:program_stream_id])
    @clients = Client.non_exited_ngo.where(id: params[:client_ids])
  end

  def referrals
    respond_to do |format|
      format.html do
        @unsaved_referrals = @notification.unsaved_referrals
      end
      format.js do
        @referrals = mapping_referrals
      end
    end
  end

  def repeat_referrals
    respond_to do |format|
      format.html do
        @repeat_referrals = @notification.repeat_referrals
      end
      format.js do
        @referrals = mapping_repeated_referrals
      end
    end
  end

  def family_referrals
    respond_to do |format|
      format.html do
        @unsaved_family_referrals = @notification.unsaved_family_referrals
      end
      format.js do
        @referrals = mapping_family_referrals
      end
    end
  end

  def repeat_family_referrals
    @repeat_family_referrals = mapping_repeat_family_referrals
  end

  def notify_user_custom_field
    @user_custom_form_notifications = mapping_notify_user_custom_field
  end

  def notify_family_custom_field
    @family_custom_form_notifications = mapping_notify_family_custom_field
  end

  def notify_partner_custom_field
    @partner_custom_form_notifications = mapping_notify_partner_custom_field
  end

  def notify_overdue_case_note
    setting = Setting.first
    max_case_note = setting.try(:max_case_note) || 30
    case_note_frequency = setting.try(:case_note_frequency) || 'day'
    client_ids = Client.accessible_by(current_ability).active_accepted_status.ids
    @case_note_notifications = CaseNote.joins(:client).where('clients.id IN (?)', client_ids)
                                       .where("DATE(case_notes.meeting_date + interval '#{max_case_note}' #{case_note_frequency}) < CURRENT_DATE")
                                       .select(:id, :meeting_date, "clients.slug client_slug, TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name")
                                       .distinct.to_a.group_by { |case_note| [case_note.client_slug, case_note.client_name] }
  end

  private

  def entity_custom_field_notification(entity_custom_field)
    @entity_custom_field_notifcation = case entity_custom_field
                                       when 'client_due_today' then @notification.client_custom_field_frequency_due_today
                                       when 'client_overdue' then @notification.client_custom_field_frequency_overdue
                                       when 'user_due_today' then @notification.user_custom_field_frequency_due_today
                                       when 'user_overdue' then @notification.user_custom_field_frequency_overdue
                                       when 'partner_due_today' then @notification.partner_custom_field_frequency_due_today
                                       when 'partner_overdue' then @notification.partner_custom_field_frequency_overdue
                                       when 'family_due_today' then @notification.family_custom_field_frequency_due_today
                                       when 'family_overdue' then @notification.family_custom_field_frequency_overdue
                                       end
  end

  def client_enrollment_tracking_notification(client_enrollment_tracking)
    @client_enrollment_tracking_notification = case client_enrollment_tracking
                                               when 'client_enrollment_tracking_due_today' then @notification.client_enrollment_tracking_frequency_due_today
                                               when 'client_enrollment_tracking_overdue' then @notification.client_enrollment_tracking_frequency_overdue
                                               end
  end
end
