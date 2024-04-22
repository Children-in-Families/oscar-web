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
end
