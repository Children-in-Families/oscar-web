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
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, custom_field_id, custom_formable_id, custom_formable_type,
            RANK() OVER (PARTITION BY custom_field_id, custom_formable_id ORDER BY created_at DESC)
            custom_fild_id_rank FROM custom_field_properties WHERE custom_formable_type = 'User'
          ) group_cp
        WHERE custom_fild_id_rank = 1
        ORDER BY custom_field_id, custom_formable_id
      )
      SELECT
        cp.custom_formable_id AS user_id,
        le.created_at,
        TRIM(CONCAT(u.first_name, ' ', u.last_name)) as user_name,
        cf.form_title
      FROM latest_entries le
      INNER JOIN custom_field_properties cp ON le.id = cp.id AND le.created_at = cp.created_at
      INNER JOIN custom_fields cf ON cp.custom_field_id = cf.id
      INNER JOIN users u ON cp.custom_formable_id = u.id
      WHERE cp.custom_formable_type = 'User'
      AND u.id IN (#{user_ids.join(', ')})
      AND DATE(cp.created_at + (cf.time_of_frequency || ' ' || CASE cf.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{sql}
      ORDER BY cp.custom_formable_id;
    SQL

    user_tracking_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, enrollment_id, tracking_id,
            RANK() OVER (PARTITION BY tracking_id, enrollment_id ORDER BY created_at DESC) tracking_id_rank
            FROM enrollment_trackings
          ) group_et
        WHERE tracking_id_rank = 1
        ORDER BY tracking_id, enrollment_id
      )
      SELECT
        e.programmable_id AS user_id,
        le.created_at,
        TRIM(CONCAT(u.first_name, ' ', u.last_name)) as user_name,
        CONCAT(t.name, ' ', '(Tracking form)') as form_title
      FROM latest_entries le
      INNER JOIN enrollment_trackings et ON le.id = et.id AND le.created_at = et.created_at
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      INNER JOIN enrollments e ON e.id = et.enrollment_id AND e.deleted_at IS NULL AND e.programmable_type = 'User'
      INNER JOIN users u ON u.id = e.programmable_id AND u.deleted_at IS NULL
      WHERE e.status = 'Active'
       AND u.id IN (#{user_ids.join(', ')})
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      ORDER BY et.enrollment_id;
    SQL

    user_custom_forms = CustomFieldProperty.find_by_sql(user_custom_form_sql) + EnrollmentTracking.find_by_sql(user_tracking_sql)
    user_custom_forms.group_by { |form| [form.user_id, form.user_name] }.to_a.uniq(&:first).to_h
  end

  def mapping_notify_family_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    family_ids = Family.accessible_by(current_ability).ids
    sql = "AND cf.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    family_custom_form_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, custom_field_id, custom_formable_id, custom_formable_type,
            RANK() OVER (PARTITION BY custom_field_id, custom_formable_id ORDER BY created_at DESC)
            custom_fild_id_rank FROM custom_field_properties WHERE custom_formable_type = 'Family'
          ) group_cp
        WHERE custom_fild_id_rank = 1
        ORDER BY custom_field_id, custom_formable_id
      )
      SELECT
        cp.custom_formable_id AS family_id,
        le.created_at,
        TRIM(CONCAT(f.name, ' ', f.name_en)) as family_name,
        cf.form_title
      FROM latest_entries le
      INNER JOIN custom_field_properties cp ON le.id = cp.id AND le.created_at = cp.created_at
      INNER JOIN custom_fields cf ON cp.custom_field_id = cf.id
      INNER JOIN families f ON cp.custom_formable_id = f.id
      WHERE cp.custom_formable_type = 'Family'
      AND f.id IN (#{family_ids.join(', ')})
      AND DATE(cp.created_at + (cf.time_of_frequency || ' ' || CASE cf.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{sql}
      ORDER BY cp.custom_formable_id;
    SQL

    family_tracking_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, enrollment_id, tracking_id,
            RANK() OVER (PARTITION BY tracking_id, enrollment_id ORDER BY created_at DESC) tracking_id_rank
            FROM enrollment_trackings
          ) group_et
        WHERE tracking_id_rank = 1
        ORDER BY tracking_id, enrollment_id
      )
      SELECT
        e.programmable_id AS family_id,
        le.created_at,
        TRIM(CONCAT(f.name, ' ', f.name_en)) as family_name,
        CONCAT(t.name, ' ', '(Tracking form)') as form_title
      FROM latest_entries le
      INNER JOIN enrollment_trackings et ON le.id = et.id AND le.created_at = et.created_at
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      INNER JOIN enrollments e ON e.id = et.enrollment_id AND e.deleted_at IS NULL AND e.programmable_type = 'Family'
      INNER JOIN families f ON f.id = e.programmable_id AND f.deleted_at IS NULL
      WHERE e.status = 'Active'
       AND f.id IN (#{family_ids.join(', ')})
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      ORDER BY et.enrollment_id;
    SQL

    family_custom_forms = CustomFieldProperty.find_by_sql(family_custom_form_sql) + EnrollmentTracking.find_by_sql(family_tracking_sql)
    family_custom_forms.group_by { |form| [form.family_id, form.family_name] }.to_a.uniq(&:first).to_h
  end

  def mapping_notify_partner_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?
    partner_ids = Partner.accessible_by(current_ability).ids

    partner_custom_form_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, custom_field_id, custom_formable_id, custom_formable_type,
            RANK() OVER (PARTITION BY custom_field_id, custom_formable_id ORDER BY created_at DESC)
            custom_fild_id_rank FROM custom_field_properties WHERE custom_formable_type = 'Partner'
          ) group_cp
        WHERE custom_fild_id_rank = 1
        ORDER BY custom_field_id, custom_formable_id
      )
      SELECT
        cp.custom_formable_id AS partner_id,
        le.created_at,
        p.name as partner_name,
        cf.form_title
      FROM latest_entries le
      INNER JOIN custom_field_properties cp ON le.id = cp.id AND le.created_at = cp.created_at
      INNER JOIN custom_fields cf ON cp.custom_field_id = cf.id
      INNER JOIN partners p ON cp.custom_formable_id = p.id
      WHERE cp.custom_formable_type = 'Partner'
      AND p.id IN (#{partner_ids.join(', ')})
      AND DATE(cp.created_at + (cf.time_of_frequency || ' ' || CASE cf.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{sql}
      ORDER BY cp.custom_formable_id;
    SQL

    partner_tracking_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, enrollment_id, tracking_id,
            RANK() OVER (PARTITION BY tracking_id, enrollment_id ORDER BY created_at DESC) tracking_id_rank
            FROM enrollment_trackings
          ) group_et
        WHERE tracking_id_rank = 1
        ORDER BY tracking_id, enrollment_id
      )
      SELECT
        e.programmable_id AS partner_id,
        le.created_at,
        p.name as partner_name,
        CONCAT(t.name, ' ', '(Tracking form)') as form_title
      FROM latest_entries le
      INNER JOIN enrollment_trackings et ON le.id = et.id AND le.created_at = et.created_at
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      INNER JOIN enrollments e ON e.id = et.enrollment_id AND e.deleted_at IS NULL AND e.programmable_type = 'Family'
      INNER JOIN partners p ON p.id = e.programmable_id
      WHERE e.status = 'Active'
       AND p.id IN (#{partner_ids.join(', ')})
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      ORDER BY et.enrollment_id;
    SQL

    partner_custom_forms = CustomFieldProperty.find_by_sql(partner_custom_form_sql) + EnrollmentTracking.find_by_sql(partner_tracking_sql)
    partner_custom_forms.group_by { |form| [form.partner_id, form.partner_name] }.to_a.uniq(&:first).to_h
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
    sql = "AND cf.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    custom_form_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, custom_field_id, custom_formable_id, custom_formable_type,
            RANK() OVER (PARTITION BY custom_field_id, custom_formable_id ORDER BY created_at DESC)
            custom_fild_id_rank FROM custom_field_properties
          ) group_cp
        WHERE custom_fild_id_rank = 1 AND custom_formable_type = 'Client'
        ORDER BY custom_field_id, custom_formable_id
      )
      SELECT
        cp.id,
        le.created_at,
        c.slug as client_slug,
        TRIM(CONCAT(CONCAT(c.given_name, ' ', c.family_name), ' ', CONCAT(c.local_family_name, ' ', c.local_given_name))) as client_name,
        cf.form_title
      FROM latest_entries le
      INNER JOIN custom_field_properties cp ON le.id = cp.id AND le.created_at = cp.created_at
      INNER JOIN custom_fields cf ON cp.custom_field_id = cf.id
      INNER JOIN clients c ON cp.custom_formable_id = c.id
      WHERE cp.custom_formable_type = 'Client'
      AND DATE(cp.created_at + (cf.time_of_frequency || ' ' || CASE cf.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{sql}
      ORDER BY cp.custom_formable_id;
    SQL

    tracking_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, tracking_id, client_enrollment_id,
            RANK() OVER (PARTITION BY tracking_id, client_enrollment_id ORDER BY created_at DESC) tracking_id_rank
            FROM client_enrollment_trackings
          ) group_cp
        WHERE tracking_id_rank = 1
        ORDER BY tracking_id, client_enrollment_id
      )
      SELECT
        cet.id,
        le.created_at,
        c.slug as client_slug,
        TRIM(CONCAT(CONCAT(c.given_name, ' ', c.family_name), ' ', CONCAT(c.local_family_name, ' ', c.local_given_name))) as client_name,
        CONCAT(t.name, ' ', '(Tracking form)') as form_title
      FROM latest_entries le
      INNER JOIN client_enrollment_trackings cet ON le.id = cet.id AND le.created_at = cet.created_at
      INNER JOIN trackings t ON t.id = cet.tracking_id AND t.deleted_at IS NULL
      INNER JOIN client_enrollments ce ON ce.id = cet.client_enrollment_id AND ce.deleted_at IS NULL
      INNER JOIN clients c ON c.id = ce.client_id
      WHERE ce.status = 'Active'
      AND DATE(cet.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      ORDER BY cet.client_enrollment_id;
    SQL

    client_custom_form_notifications = CustomFieldProperty.find_by_sql(custom_form_sql) + ClientEnrollmentTracking.find_by_sql(tracking_sql)

    # group_forms = client_custom_form_notifications.group_by { |form| [form.form_title, form.client_slug] }.map do |_, values|
    #   values.max_by(&:created_at)
    # end

    client_custom_form_notifications.group_by { |form| [form.client_slug, form.client_name] }.to_a.uniq(&:first).to_h
  end

  def fetch_client_by_sql(client_ids, sql)
    client_ids.any? ? Client.find_by_sql(sql).to_a : Client.none
  end
end
