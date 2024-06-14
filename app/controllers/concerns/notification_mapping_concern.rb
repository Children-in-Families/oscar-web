module NotificationMappingConcern
  def map_notification_payloads(notifications = {})
    data = {
      assessment: assessment_payload(notifications),
      custom_assessment: custom_assessment_payload(notifications),
      user_custom_forms: custom_forms_payload(notifications, 'user_custom_field', '/api/v1/notify_user_custom_field'),
      client_custom_forms: client_custom_forms_payload(notifications),
      family_custom_forms: custom_forms_payload(notifications, 'family_custom_field', '/api/v1/notify_family_custom_field'),
      partner_custom_forms: custom_forms_payload(notifications, 'partner_custom_field', '/api/v1/notify_partner_custom_field'),
      case_notes: case_notes_payload(notifications),
      get_referrals: client_referral_payload(notifications, 'get_referrals'),
      family_referrals: family_referrals_payload(notifications, 'unsaved_family_referrals'),
      tasks: tasks_payload(notifications),
      review_program_streams: {
        data: review_program_stream_mapping(notifications['review_program_streams'] || []),
        path: '/api/v1/notifications/program_stream_notify'
      }
    }

    count = 0
    data.each do |_, v|
      count += 1 unless (v[:overdue_count] || v[:new_count] || v[:repeated_count] || 0).zero?
    end

    data.each do |_, v|
      count += 1 unless (v[:repeated_count] || 0).zero?
    end

    data.merge({ all_count: count })
  end

  def review_program_stream_mapping(review_program_streams)
    review_program_streams.map { |review_program_stream| [review_program_stream.first['id'], review_program_stream.first['name'], review_program_stream.last] }
  end

  def assessment_payload(notifications)
    {
      overdue_count: notifications.dig('assessments', 'overdue_count'),
      due_today_count: notifications.dig('assessments', 'due_today') || 0,
      upcoming_csi_count: notifications['upcoming_csi_assessments_count'],
      path: '/api/v1/notifications/notify_assessment'
    }
  end

  def custom_assessment_payload(notifications)
    {
      overdue_count: notifications.dig('assessments', 'custom_overdue_count'),
      due_today_count: notifications.dig('assessments', 'custom_due_today') || 0,
      upcoming_count: notifications['upcoming_custom_csi_assessments_count'],
      path: '/api/v1/notifications/notify_custom_assessment'
    }
  end

  def custom_forms_payload(notifications, key, path)
    {
      overdue_count: notifications.dig(key, 'entity_overdue').try(:size) || 0,
      due_today_count: notifications.dig(key, 'entity_due_today').try(:size) || 0,
      path: path
    }
  end

  def client_custom_forms_payload(notifications)
    {
      overdue_count: notifications.dig('client_forms_overdue_or_due_today', 'overdue_forms').try(:size) || 0,
      due_today_count: notifications.dig('client_forms_overdue_or_due_today', 'today_forms').try(:size) || 0,
      upcoming_count: notifications.dig('client_forms_overdue_or_due_today', 'upcoming_forms').try(:size) || 0,
      path: '/api/v1/notifications/notify_client_custom_form'
    }
  end

  def case_notes_payload(notifications)
    {
      overdue_count: notifications.dig('case_notes_overdue_and_due_today', 'client_overdue').try(:size) || 0,
      due_today_count: notifications.dig('case_notes_overdue_and_due_today', 'client_due_today').try(:size) || 0,
      path: '/api/v1/notifications/notify_overdue_case_note'
    }
  end

  def client_referral_payload(notifications, key)
    {
      new_count: (notifications[key] && notifications[key][1].try(:size)) || 0,
      repeated_count: (notifications[key] && notifications[key][0].try(:size)) || 0,
      new_referral_path: '/api/v1/notifications/referrals',
      repeated_referral_path: '/api/v1/notifications/repeat_referrals'
    }
  end

  def family_referrals_payload(notifications, key)
    {
      new_count: (notifications['unsaved_family_referrals'] && notifications['unsaved_family_referrals'].try(:size)) || 0,
      repeated_count: (notifications['repeat_family_referrals'] && notifications['repeat_family_referrals'].try(:size)) || 0,
      new_referral_path: '/api/v1/notifications/family_referrals',
      repeated_referral_path: '/api/v1/notifications/repeat_family_referrals'
    }
  end

  def tasks_payload(notifications)
    {
      overdue_count: notifications['overdue_tasks_count'],
      due_today_count: notifications['due_today_tasks_count'],
      upcoming_csi_count: notifications['upcoming_tasks_count'],
      path: '/api/v1/notifications/notify_task'
    }
  end
end
