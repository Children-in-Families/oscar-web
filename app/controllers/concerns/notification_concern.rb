module NotificationConcern
  include ReferralsHelper

  def mapping_referrals
    find_new_and_existing_referrals(current_user).last
  end

  def mapping_repeated_referrals
    find_new_and_existing_referrals(current_user).first
  end

  def mapping_family_referrals
    new_family_referrals = []
    if current_user.deactivated_at.nil?
      referrals = FamilyReferral.received.unsaved
    else
      referrals = FamilyReferral.received.unsaved.where('created_at > ?', current_user.activated_at)
    end

    referrals.each do |referral|
      referral_slug = referral.slug
      family = Family.find_by(slug: referral_slug)
      new_family_referrals << referral if family.nil?
    end

    new_family_referrals
  end

  def mapping_repeat_family_referrals
    existing_family_referrals = []
    if current_user.deactivated_at.nil?
      referrals = FamilyReferral.received.unsaved
    else
      referrals = FamilyReferral.received.unsaved.where('created_at > ?', current_user.activated_at)
    end

    referrals.each do |referral|
      referral_slug = referral.slug
      family = Family.find_by(slug: referral_slug)
      existing_family_referrals << referral if family.present?
    end

    existing_family_referrals
  end

  def mapping_notify_user_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    user_ids = User.accessible_by(current_ability).ids
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    user_custom_form_sql = <<~SQL
      SELECT s.id,
      custom_fields.form_title,
      MAX(cfp.created_at) AS max_created_at,
      TRIM(CONCAT(s.first_name, ' ', s.last_name)) as user_name
      FROM users s
      INNER JOIN custom_field_properties cfp ON cfp.custom_formable_id = s.id
      AND cfp.custom_formable_type = 'User'
      INNER JOIN custom_fields ON custom_fields.id = cfp.custom_field_id
      WHERE cfp.created_at = (
          SELECT MAX(created_at)
          FROM custom_field_properties cfp2
          WHERE cfp2.custom_formable_id = cfp.custom_formable_id AND cfp2.custom_formable_type = 'User'
      )
      AND DATE(cfp.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND s.deleted_at IS NULL
      AND s.id IN (#{user_ids.join(', ')})
      #{sql}
      GROUP BY s.id, custom_fields.form_title;
    SQL

    user_tracking_sql = <<~SQL
      SELECT s.id,
      t.name form_title,
      MAX(et.created_at) AS max_created_at,
      TRIM(CONCAT(s.first_name, ' ', s.last_name)) as user_name
      FROM users s
      INNER JOIN enrollments e ON e.programmable_id = s.id
      AND e.deleted_at IS NULL AND e.programmable_type = 'User'
      INNER JOIN enrollment_trackings et ON et.enrollment_id = e.id
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      WHERE et.created_at = (
          SELECT MAX(created_at)
          FROM enrollment_trackings et2
          WHERE et2.enrollment_id = et.enrollment_id
      )
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND s.deleted_at IS NULL
      AND s.id IN (#{user_ids.join(', ')})
      GROUP BY s.id, t.name;
    SQL

    User.find_by_sql(user_custom_form_sql) + User.find_by_sql(user_tracking_sql)
  end

  def mapping_notify_family_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    family_ids = Family.accessible_by(current_ability).ids
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    family_custom_form_sql = <<~SQL
      SELECT f.id,
      custom_fields.form_title,
      MAX(cfp.created_at) AS max_created_at,
      TRIM(CONCAT(f.name, ' ', f.name_en)) as family_name
      FROM families f
      INNER JOIN custom_field_properties cfp ON cfp.custom_formable_id = f.id
      AND cfp.custom_formable_type = 'Family'
      INNER JOIN custom_fields ON custom_fields.id = cfp.custom_field_id
      WHERE cfp.created_at = (
          SELECT MAX(created_at)
          FROM custom_field_properties cfp2
          WHERE cfp2.custom_formable_id = cfp.custom_formable_id AND cfp2.custom_formable_type = 'Family'
      )
      AND DATE(cfp.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND f.deleted_at IS NULL
      AND f.id IN (#{family_ids.join(', ')})
      #{sql}
      GROUP BY f.id, custom_fields.form_title;
    SQL

    family_tracking_sql = <<~SQL
      SELECT f.id,
      t.name form_title,
      MAX(et.created_at) AS max_created_at,
      TRIM(CONCAT(f.name, ' ', f.name_en)) as family_name
      FROM families f
      INNER JOIN enrollments e ON e.programmable_id = f.id
      AND e.deleted_at IS NULL AND e.programmable_type = 'Family'
      INNER JOIN enrollment_trackings et ON et.enrollment_id = e.id
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      WHERE et.created_at = (
          SELECT MAX(created_at)
          FROM enrollment_trackings et2
          WHERE et2.enrollment_id = et.enrollment_id
      )
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND f.deleted_at IS NULL
      AND f.id IN (#{family_ids.join(', ')})
      GROUP BY f.id, t.name;
    SQL

    Family.find_by_sql(family_custom_form_sql) + Family.find_by_sql(family_tracking_sql)
  end

  def mapping_notify_partner_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?
    partner_ids = Partner.accessible_by(current_ability).ids

    partner_custom_form_sql = <<~SQL
      SELECT p.id,
      custom_fields.form_title,
      MAX(cfp.created_at) AS max_created_at,
      p.name as partner_name
      FROM partners p
      INNER JOIN custom_field_properties cfp ON cfp.custom_formable_id = p.id
      AND cfp.custom_formable_type = 'Partner'
      INNER JOIN custom_fields ON custom_fields.id = cfp.custom_field_id
      WHERE cfp.created_at = (
          SELECT MAX(created_at)
          FROM custom_field_properties cfp2
          WHERE cfp2.custom_formable_id = cfp.custom_formable_id AND cfp2.custom_formable_type = 'Partner'
      )
      AND DATE(cfp.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND p.id IN (#{partner_ids.join(', ')})
      #{sql}
      GROUP BY p.id, custom_fields.form_title;
    SQL

    partner_tracking_sql = <<~SQL
      SELECT p.id,
      t.name form_title,
      MAX(et.created_at) AS max_created_at,
      p.name as partner_name
      FROM partners p
      INNER JOIN enrollments e ON e.programmable_id = p.id
      AND e.deleted_at IS NULL AND e.programmable_type = 'Partner'
      INNER JOIN enrollment_trackings et ON et.enrollment_id = e.id
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      WHERE et.created_at = (
          SELECT MAX(created_at)
          FROM enrollment_trackings et2
          WHERE et2.enrollment_id = et.enrollment_id
      )
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      AND p.id IN (#{partner_ids.join(', ')})
      GROUP BY p.id, t.name;
    SQL

    Partner.find_by_sql(partner_custom_form_sql) + Partner.find_by_sql(partner_tracking_sql)
  end

  def mapping_notify_overdue_case_note
    setting = Setting.first
    max_case_note = setting.try(:max_case_note) || 30
    case_note_frequency = setting.try(:case_note_frequency) || 'day'
    client_ids = Client.accessible_by(current_ability).active_accepted_status.ids

    sql = <<~SQL
      SELECT c.id, c.slug, TRIM(CONCAT(CONCAT(c.given_name, ' ', c.family_name), ' ', CONCAT(c.local_family_name, ' ', c.local_given_name))) as client_name,
      MAX(cn.meeting_date) AS last_meeting_date
      FROM clients c
      INNER JOIN case_notes cn ON c.id = cn.client_id
      WHERE cn.meeting_date = (
          SELECT MAX(meeting_date)
          FROM case_notes cn2
          WHERE cn2.client_id = cn.client_id
      )
      AND c.id IN (#{client_ids.join(', ')})
      AND DATE(cn.meeting_date + interval '#{max_case_note}' #{case_note_frequency}) < CURRENT_DATE
      GROUP BY c.id, c.slug;
    SQL

    fetch_client_by_sql(client_ids, sql)
  end

  def mapping_notify_task
    current_user.tasks.joins(:client).overdue_incomplete.where(client_id: Client.accessible_by(current_ability).active_accepted_status.ids).select(
      :id, :name, :expected_date, 'clients.slug as client_slug',
      "TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name"
    ).to_a.group_by { |task| [task.client_slug, task.client_name] }
  end

  def mapping_notify_assessment
    setting = Setting.first
    client_ids = Client.accessible_by(current_ability).active_accepted_status.where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', setting&.age || 18).ids

    sql = <<~SQL
      SELECT c.id,
        c.slug,
        TRIM(CONCAT(CONCAT(c.given_name, ' ', c.family_name), ' ', CONCAT(c.local_family_name, ' ', c.local_given_name))) as client_name,
        MAX(a.created_at) AS last_assessment_date
      FROM clients c
      INNER JOIN assessments a ON c.id = a.client_id
      WHERE a.created_at = (
          SELECT MAX(created_at)
          FROM assessments a2
          WHERE a2.client_id = a.client_id
      )
      AND c.id IN (#{client_ids.join(', ')})
      AND (a.created_at + INTERVAL '#{setting.max_assessment} #{setting.assessment_frequency}') < CURRENT_DATE
      AND a.default = true
      AND a.draft = false
      GROUP BY c.id, a.created_at;
    SQL

    fetch_client_by_sql(client_ids, sql)
  end

  def mapping_notify_custom_assessment
    CustomAssessmentSetting.only_enable_custom_assessment.map do |custom_setting|
      client_ids = Client.accessible_by(current_ability).active_accepted_status.where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', custom_setting&.custom_age || 18).ids
      sql = <<~SQL
        SELECT
          c.id,
          c.slug,
          TRIM(CONCAT(CONCAT(c.given_name, ' ', c.family_name), ' ', CONCAT(c.local_family_name, ' ', c.local_given_name))) as client_name,
          MAX(a.created_at) AS last_assessment_date
        FROM clients c
        INNER JOIN assessments a ON c.id = a.client_id
        WHERE a.created_at = (
            SELECT MAX(created_at)
            FROM assessments a2
            WHERE a2.client_id = a.client_id AND a.custom_assessment_setting_id = #{custom_setting.id}
        )
        AND c.id IN (#{client_ids.join(', ')})
        AND #{custom_setting.custom_assessment_frequency == 'unlimited' ? 'DATE(a.created_at) < CURRENT_DATE' : "DATE(a.created_at + interval '#{custom_setting.max_custom_assessment} #{custom_setting.custom_assessment_frequency}') < CURRENT_DATE"}
        AND a.default = false
        AND a.draft = false
        GROUP BY c.id, a.created_at;
      SQL

      custom_assessments = fetch_client_by_sql(client_ids, sql)

      [custom_setting.custom_assessment_name, custom_assessments]
    end
  end

  def mapping_notify_client_custom_form
    setting = Setting.first
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    client_ids = Client.accessible_by(current_ability).active_accepted_status
                       .where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', setting&.age || 18).ids
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    client_custom_form_notifications = CustomFieldProperty.joins(:custom_field, :client)
                                                          .where("custom_fields.frequency != '' AND custom_field_properties.custom_formable_type = 'Client' AND custom_field_properties.custom_formable_id IN (?) #{sql}", client_ids)
                                                          .where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                          .select(:id, :created_at, "custom_fields.form_title, clients.slug client_slug, TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name")
                                                          .distinct.to_a

    client_custom_form_notifications += ClientEnrollmentTracking.joins(:tracking, client_enrollment: :client)
                                                                .where("trackings.frequency != '' AND client_enrollments.status = 'Active' AND client_enrollments.client_id IN (?)", client_ids)
                                                                .where("DATE(client_enrollment_trackings.created_at + (trackings.time_of_frequency || ' ' || CASE trackings.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                                .select(:id, :created_at, "trackings.name form_title, clients.slug client_slug, TRIM(CONCAT(CONCAT(clients.given_name, ' ', clients.family_name), ' ', CONCAT(clients.local_family_name, ' ', clients.local_given_name))) as client_name")
                                                                .distinct.to_a

    group_forms = client_custom_form_notifications.group_by { |form| [form.form_title, form.client_slug] }.map do |_, values|
      values.max_by(&:created_at)
    end

    group_forms.group_by { |form| [form.client_slug, form.client_name] }.to_a.uniq(&:first).to_h
  end

  def fetch_client_by_sql(client_ids, sql)
    client_ids.any? ? Client.find_by_sql(sql).to_a : Client.none
  end
end
