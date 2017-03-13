module EntityTypeCustomFieldNotification
  def entity_type_custom_field_notification(entity)
    entity_due_today = []
    entity_overdue = []
    entity.each do |entity|
      entity.custom_fields.uniq.each do |custom_field|
        if custom_field.frequency.present?
          if entity.next_custom_field_date(entity, custom_field) < Date.today
            entity_overdue << entity
          elsif entity.next_custom_field_date(entity, custom_field) == Date.today
            entity_due_today << entity
          end
        end
      end
    end
    { entity_due_today: entity_due_today.uniq, entity_overdue: entity_overdue.uniq}
  end
end
