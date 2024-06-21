module EntityTypeCustomFieldNotification
  def entity_type_custom_field_notification(user, klass_name, entities)
    custom_field_ids = user.custom_field_permissions.where(editable: false).pluck(:custom_field_id)
    sql = "AND custom_fields.id NOT IN (#{custom_field_ids.join(',')})" if (user.case_worker? || user.manager?) && custom_field_ids.any?
    if sql
      entity_ids = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).where(sql).ids
    else
      entity_ids = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).ids
    end
    entity_ids_sql = entity_ids.any? ? "AND entity.id IN (#{entity_ids.join(', ')})" : ''

    table_name = klass_name.downcase.pluralize

    enttity_custom_form_sql = <<~SQL
      SELECT entity.id,
      MAX(cfp.created_at) AS max_created_at
      FROM #{table_name} entity
      INNER JOIN custom_field_properties cfp ON cfp.custom_formable_id = entity.id
      AND cfp.custom_formable_type = '#{klass_name}'
      INNER JOIN custom_fields ON custom_fields.id = cfp.custom_field_id
      WHERE cfp.created_at = (
          SELECT MAX(created_at)
          FROM custom_field_properties cfp2
          WHERE cfp2.custom_formable_id = cfp.custom_formable_id AND cfp2.custom_formable_type = '#{klass_name}'
      )
      AND DATE(cfp.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{entity_ids_sql}
      GROUP BY entity.id, custom_fields.form_title;
    SQL

    family_tracking_sql = <<~SQL
      SELECT entity.id,
      t.name form_title
      FROM #{table_name} entity
      INNER JOIN enrollments e ON e.programmable_id = entity.id
      AND e.deleted_at IS NULL AND e.programmable_type = '#{klass_name}'
      INNER JOIN enrollment_trackings et ON et.enrollment_id = e.id
      INNER JOIN trackings t ON t.id = et.tracking_id AND t.deleted_at IS NULL
      WHERE et.created_at = (
          SELECT MAX(created_at)
          FROM enrollment_trackings et2
          WHERE et2.enrollment_id = et.enrollment_id
      )
      AND DATE(et.created_at + (t.time_of_frequency || ' ' || CASE t.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE
      #{entity_ids_sql}
      GROUP BY entity.id, t.name;
    SQL

    entity_overdue = klass_name.constantize.find_by_sql(enttity_custom_form_sql) + klass_name.constantize.find_by_sql(family_tracking_sql)
    entity_due_today = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' }).where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) = CURRENT_DATE")

    { entity_due_today: entity_due_today.to_a.uniq, entity_overdue: entity_overdue.to_a }
  end
end
