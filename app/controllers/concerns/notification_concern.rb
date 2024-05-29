module NotificationConcern
  def mapping_referrals
    referrals = Referral.received.unsaved
    referrals = referrals.where('created_at > ?', current_user.activated_at) if current_user.deactivated_at?

    referrals.where(client_id: nil)
  end

  def mapping_repeated_referrals
    referrals = Referral.received.unsaved
    referrals = referrals.where('created_at > ?', @current_user.activated_at) if current_user.deactivated_at?
    slugs = referrals.pluck(:slug).select(&:present?).uniq
    clients = Client.where('slug IN (:slugs) OR archived_slug IN (:slugs)', slugs: slugs)
    existinngs = []

    referrals.each do |referral|
      client = clients.find { |c| c.global_id == referral.client_global_id || c.id == referral.client_id }
      next unless client&.slug

      if client.present?
        existinngs << referral
        referral.update_column(:client_id, client.id) unless referral.client_id
      end
    end

    existinngs
  end

  def mapping_family_referrals
    if current_user.deactivated_at.nil?
      referrals = FamilyReferral.received.unsaved
    else
      referrals = FamilyReferral.received.unsaved.where('created_at > ?', current_user.activated_at)
    end

    referrals.where(slug: nil)
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

    user_custom_form_notifications = CustomFieldProperty.joins(:custom_field, :user)
                                                        .where("custom_fields.frequency != '' AND custom_field_properties.custom_formable_type = 'User' AND custom_field_properties.custom_formable_id IN (?) #{sql}", user_ids)
                                                        .where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                        .select(:id, :created_at, "custom_fields.form_title, users.id user_id, TRIM(CONCAT(users.first_name, ' ', users.last_name)) as user_name")
                                                        .distinct.to_a

    user_custom_form_notifications.group_by { |form| [form.user_id, form.user_name] }
  end

  def mapping_notify_family_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    family_ids = Family.accessible_by(current_ability).ids
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    family_custom_form_notifications = CustomFieldProperty.joins(:custom_field, :family)
                                                          .where("custom_fields.frequency != '' AND custom_field_properties.custom_formable_type = 'Family' AND custom_field_properties.custom_formable_id IN (?) #{sql}", family_ids)
                                                          .where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                          .select(:id, :created_at, "custom_fields.form_title, families.id family_id, TRIM(CONCAT(families.name, ' ', families.name_en)) as family_name")
                                                          .distinct.to_a

    family_custom_form_notifications += EnrollmentTracking.joins(:tracking, enrollment: :family)
                                                          .where("trackings.frequency != '' AND enrollments.status = 'Active' AND enrollments.programmable_id IN (?)", family_ids)
                                                          .where("DATE(enrollment_trackings.created_at + (trackings.time_of_frequency || ' ' || CASE trackings.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                          .select(:id, :created_at, "trackings.name form_title, families.id family_id, TRIM(CONCAT(families.name, ' ', families.name_en)) as family_name")
                                                          .distinct.to_a

    family_custom_form_notifications.group_by { |form| [form.family_id, form.family_name] }
  end

  def mapping_notify_partner_custom_field
    custom_field_ids = current_user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (current_user.case_worker? || current_user.manager?) && custom_field_ids.any?

    user_custom_form_notifications = CustomFieldProperty.joins(:custom_field, :partner)
                                                        .where("custom_fields.frequency != '' #{sql}")
                                                        .where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
                                                        .select(:id, :created_at, 'custom_fields.form_title, partners.id partner_id, partners.name as partner_name')
                                                        .distinct.to_a

    user_custom_form_notifications.group_by { |form| [form.partner_id, form.partner_name] }
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

    Client.find_by_sql(sql)
  end

  def mapping_notify_task
    current_user.tasks.overdue_incomplete.exclude_exited_ngo_clients.joins(:client).select(
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

    Client.find_by_sql(sql)
          .to_a
  end

  def mapping_notify_custom_assessment
    CustomAssessmentSetting.only_enable_custom_assessment.map do |custom_setting|
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
        AND #{custom_setting.custom_assessment_frequency == 'unlimited' ? 'DATE(a.created_at) < CURRENT_DATE' : "DATE(a.created_at + interval '#{custom_setting.max_custom_assessment} #{custom_setting.custom_assessment_frequency}') < CURRENT_DATE"}
        AND a.default = false
        AND a.draft = false
        GROUP BY c.id, a.created_at;
      SQL

      custom_assessments = Client.accessible_by(current_ability)
                                 .active_accepted_status.where('(EXTRACT(year FROM age(current_date, coalesce(clients.date_of_birth, CURRENT_DATE))) :: int) < ?', custom_setting&.custom_age || 18)
                                 .find_by_sql(sql)
                                 .to_a

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

    client_custom_form_notifications.group_by { |form| [form.client_slug, form.client_name] }
  end
end
