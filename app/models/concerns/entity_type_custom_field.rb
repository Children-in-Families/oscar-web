module EntityTypeCustomField
  def next_custom_field_date(entity, custom_field)
    entity.custom_field_properties.by_custom_field(custom_field).last.created_at.to_date + custom_field_frequency(custom_field)
  end

  private

  def custom_field_frequency(custom_field)
    frequency = custom_field.frequency
    time_of_frequency = custom_field.time_of_frequency
    case frequency
    when 'Daily' then time_of_frequency.day
    when 'Weekly' then time_of_frequency.week
    when 'Monthly' then time_of_frequency.month
    when 'Yearly' then time_of_frequency.year
    else 0.day
    end
  end
end
