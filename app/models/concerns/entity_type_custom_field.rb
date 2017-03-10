module EntityTypeCustomField
  def can_create_next_custom_field?(entity, custom_field)
    Date.today >= next_custom_field_date(entity, custom_field)
  end

  private

  def next_custom_field_date(entity, custom_field)
    case custom_field.entity_type
    when 'Client'  then entity.client_custom_fields.by_custom_field(custom_field).last.created_at.to_date + custom_field_frequency(custom_field)
    when 'Family'  then entity.family_custom_fields.by_custom_field(custom_field).last.created_at.to_date + custom_field_frequency(custom_field)
    when 'Partner' then entity.partner_custom_fields.by_custom_field(custom_field).last.created_at.to_date + custom_field_frequency(custom_field)
    when 'User'    then entity.user_custom_fields.by_custom_field(custom_field).last.created_at.to_date + custom_field_frequency(custom_field)
    end
  end

  def custom_field_frequency(custom_field)
    frequency         = custom_field.frequency
    time_of_frequency = custom_field.time_of_frequency
    case frequency
    when 'Day'   then time_of_frequency.day
    when 'Week'  then time_of_frequency.week
    when 'Month' then time_of_frequency.month
    when 'Year'  then time_of_frequency.year
    else 0.day
    end
  end
end
