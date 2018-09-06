class RemindManagerMailer < ApplicationMailer
  def case_worker_overdue_tasks_notify(manager, case_workers, org_name)
    @org_name     = org_name
    @manager      = manager
    csi_setting   = Setting.first.try(:disable_assessment)
    @csi_setting  = csi_setting.nil? ? true : !csi_setting
    @subject      = @csi_setting ? 'Case workers have overdue assessments, tasks or forms that are more than a week overdue' : 'Case workers have overdue tasks or forms that are more than a week overdue'
    @case_workers = case_workers_overdue_tasks(case_workers)
    return unless @case_workers.present?
    mail(to: @manager.email, subject: @subject)
  end

  def case_workers_overdue_tasks(users)
    case_workers = []
    users.each do |user|
      overdue_forms = []
      overdue_tasks = []
      overdue_assessments = []
      user.clients.active_accepted_status.each do |client|
        break if overdue_forms.present? || overdue_tasks.present? || overdue_assessments.present?
        client_overdue_tasks = client.tasks.incomplete.exclude_exited_ngo_clients.of_user(user).incomplete.where('completion_date <= ?', 7.days.ago)
        overdue_tasks << client_overdue_tasks if client_overdue_tasks.present?
        overdue_assessments << client.next_assessment_date if client.next_assessment_date <= 7.days.ago

        custom_fields = client.custom_fields.where.not(frequency: '')
        custom_fields.each do |custom_field|
          overdue_forms << custom_field.form_title if client.next_custom_field_date(client, custom_field) <= 7.days.ago
        end

        client_active_enrollments = client.client_enrollments.active
        client_active_enrollments.each do |client_active_enrollment|
          trackings = client_active_enrollment.trackings.where.not(frequency: '')
          trackings.each do |tracking|
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            overdue_forms << tracking.name if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) <= 7.days.ago
          end
        end
      end
      overdue_assessments = @csi_setting ? overdue_assessments : []
      case_workers << user if overdue_forms.present? || overdue_tasks.present? || overdue_assessments.present?
    end
    case_workers
  end
end
