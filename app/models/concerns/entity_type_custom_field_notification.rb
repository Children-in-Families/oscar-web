module EntityTypeCustomFieldNotification
  def entity_type_custom_field_notification(entities)
    entities = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' })

    entity_overdue = entities.where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) < CURRENT_DATE")
    entity_due_today = entities.where("DATE(custom_field_properties.created_at + (custom_fields.time_of_frequency || ' ' || CASE custom_fields.frequency WHEN 'Daily' THEN 'day' WHEN 'Weekly' THEN 'week' WHEN 'Monthly' THEN 'month' WHEN 'Yearly' THEN 'year' END)::interval) = CURRENT_DATE")

    { entity_due_today: entity_due_today.to_a.uniq, entity_overdue: entity_overdue.to_a.uniq }
  end
end
