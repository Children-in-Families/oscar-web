module EntityTypeCustomFieldNotification
  def entity_type_custom_field_notification(entities)
    entity_due_today = []
    entity_overdue = []
    entities = entities.joins(:custom_fields).where.not(custom_fields: { frequency: '' })

    entities.each do |entity|
      entity.custom_fields.where.not(custom_fields: { frequency: '' }).uniq.each do |custom_field|
        if next_custom_field_date(entity, custom_field) < Date.today
          entity_overdue << entity
        elsif next_custom_field_date(entity, custom_field) == Date.today
          entity_due_today << entity
        end
      end
    end
    { entity_due_today: entity_due_today.uniq, entity_overdue: entity_overdue.uniq}
  end
end
