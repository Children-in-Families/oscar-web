module ClientOverdueAndDueTodayForms
  include CsiConcern

  def overdue_and_due_today_forms(user, clients)
    overdue_forms = []
    today_forms = []
    upcoming_forms = []
    @setting = Setting.first
    if user.admin?
      editable_clients = clients
    else
      custom_field_ids = user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
      editable_clients = clients.where.not(id: CustomFieldProperty.where(custom_formable_type: 'Client', custom_field_id: custom_field_ids).select(:custom_formable_id))
    end
    eligible_clients = active_young_clients(editable_clients, @setting)
    eligible_clients.each do |client|
      custom_fields = client.custom_fields.where.not(frequency: '')
      client_active_enrollments = client.client_enrollments.active

      custom_fields.each do |custom_field|
        if client.next_custom_field_date(client, custom_field) < Date.today
          overdue_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        elsif client.next_custom_field_date(client, custom_field) == Date.today
          today_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        elsif client.next_custom_field_date(client, custom_field).between?(Date.tomorrow, 3.months.from_now)
          upcoming_forms << [custom_field.form_title, custom_field.custom_field_properties.where(custom_formable_id: client.id).last.created_at]
        end
      end

      client_active_enrollments.each do |client_active_enrollment|
        trackings = client_active_enrollment.trackings.where.not(frequency: '')
        trackings.each do |tracking|
          last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
          if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
            overdue_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) == Date.today
            today_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking).between?(Date.tomorrow, 3.months.from_now)
            upcoming_forms << [tracking.name, last_client_enrollment_tracking.created_at]
          end
        end
      end
    end

    { overdue_forms: overdue_forms.uniq, today_forms: today_forms.uniq, upcoming_forms: upcoming_forms.uniq }
  end
end
