module NotificationMappingConcern
  def map_notification_payloads(notifications = {})
    {
      all_count: notifications['all_count'],
      assessment: assessment_payload(notifications),
      custom_assessment: custom_assessment_payload(notifications),
      user_custom_forms: custom_forms_payload(notifications, 'user_custom_field'),
      client_custom_forms: client_custom_forms_payload(notifications),
      family_custom_forms: custom_forms_payload(notifications, 'family_custom_field'),
      partner_custom_forms: custom_forms_payload(notifications, 'partner_custom_field'),
      case_notes: case_notes_payload(notifications),
      get_referrals: referrals_payload(notifications, 'get_referrals'),
      repeat_family_referrals: referrals_payload(notifications, 'repeat_family_referrals'),
      tasks: tasks_payload(notifications),
      unsaved_family_referrals: referrals_payload(notifications, 'unsaved_family_referrals'),
      review_program_streams: review_program_stream_mapping(notifications['review_program_streams'] || [])
    }
  end

  def review_program_stream_mapping(review_program_streams)
    review_program_streams.map { |review_program_stream| [review_program_stream.first['id'], review_program_stream.first['name'], review_program_stream.last] }
  end

  def assessment_payload(notifications)
    {
      overdue_count: notifications.dig('assessments', 'overdue_count'),
      due_today_count: notifications.dig('assessments', 'due_today') || 0,
      upcoming_csi_count: notifications['upcoming_csi_assessments_count'],
      path: ''
    }
  end

  def custom_assessment_payload(notifications)
    {
      overdue_count: notifications.dig('assessments', 'custom_overdue_count'),
      due_today_count: notifications.dig('assessments', 'custom_due_today') || 0,
      upcoming_count: notifications['upcoming_custom_csi_assessments_count'],
      path: ''
    }
  end

  def custom_forms_payload(notifications, key)
    {
      overdue_count: notifications.dig(key, 'entity_overdue').try(:size) || 0,
      due_today_count: notifications.dig(key, 'entity_due_today').try(:size) || 0,
      path: ''
    }
  end

  def client_custom_forms_payload(notifications)
    {
      overdue_count: notifications.dig('client_forms_overdue_or_due_today', 'overdue_forms').try(:size) || 0,
      due_today_count: notifications.dig('client_forms_overdue_or_due_today', 'today_forms').try(:size) || 0,
      upcomming_count: notifications.dig('client_forms_overdue_or_due_today', 'upcoming_forms').try(:size) || 0,
      path: ''
    }
  end

  def case_notes_payload(notifications)
    {
      overdue_count: notifications.dig('case_notes_overdue_and_due_today', 'client_overdue').try(:size) || 0,
      due_today_count: notifications.dig('case_notes_overdue_and_due_today', 'client_due_today').try(:size) || 0,
      path: ''
    }
  end

  def referrals_payload(notifications, key)
    {
      new_count: (notifications[key] && notifications[key][1].try(:size)) || 0,
      repeated_count: (notifications[key] && notifications[key][0].try(:size)) || 0,
      path: ''
    }
  end

  def tasks_payload(notifications)
    {
      overdue_count: notifications['overdue_tasks_count'],
      due_today_count: notifications['due_today_tasks_count'],
      upcoming_csi_count: notifications['upcomming_tasks_count'],
      path: ''
    }
  end
end
