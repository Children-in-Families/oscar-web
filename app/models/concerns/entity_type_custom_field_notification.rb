module EntityTypeCustomFieldNotification
  def entity_type_custom_field_notification(user, klass_name, entities)
    custom_field_ids = user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    sql = "custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (user.case_worker? || user.manager?) && custom_field_ids.any?
    if sql
      entity_ids = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).where(sql).ids
    else
      entity_ids = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).ids
    end

    entity_ids_sql = entity_ids.any? ? "AND entity.id IN (#{entity_ids.join(', ')})" : ''

    table_name = klass_name.downcase.pluralize

    entity_custom_form_sql = <<~SQL
      WITH latest_entries AS (
        SELECT id, created_at FROM (
          SELECT id, created_at, custom_field_id, custom_formable_id, custom_formable_type,
            RANK() OVER (PARTITION BY custom_field_id, custom_formable_id ORDER BY created_at DESC)
            custom_fild_id_rank FROM custom_field_properties WHERE custom_formable_type = '#{klass_name}'
          ) group_cp
        WHERE custom_fild_id_rank = 1
        ORDER BY custom_field_id, custom_formable_id
      )
      SELECT
        cp.id,
        le.created_at
      FROM latest_entries le
      INNER JOIN custom_field_properties cp ON le.id = cp.id AND le.created_at = cp.created_at
      INNER JOIN custom_fields cf ON cp.custom_field_id = cf.id
      INNER JOIN #{table_name} entity ON cp.custom_formable_id = entity.id AND cp.custom_formable_type = '#{klass_name}'
      WHERE DATE(cp.created_at + (cf.time_of_frequency || ' ' || CASE cf.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{entity_ids_sql}
      ORDER BY cp.custom_formable_id;
    SQL

    entity_tracking_sql = <<~SQL
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
        et.id,
        le.created_at
      FROM latest_entries le
      INNER JOIN enrollment_trackings et ON le.id = et.id AND le.created_at = et.created_at
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      INNER JOIN enrollments e ON e.id = et.enrollment_id AND e.deleted_at IS NULL AND e.programmable_type = '#{klass_name}'
      INNER JOIN #{table_name} entity ON entity.id = e.programmable_id
      WHERE e.status = 'Active'
      #{entity_ids_sql}
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      ORDER BY et.enrollment_id;
    SQL

    entity_overdue = CustomFieldProperty.find_by_sql(entity_custom_form_sql) + EnrollmentTracking.find_by_sql(entity_tracking_sql)
    entity_due_today = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) = CURRENT_DATE")

    { entity_due_today: entity_due_today.to_a.uniq, entity_overdue: entity_overdue.to_a }
  end
end
