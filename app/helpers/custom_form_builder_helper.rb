module CustomFormBuilderHelper
  def used_custom_form?(custom_field)
    custom_field.user.present? || custom_field.clients.present? || custom_field.partners.present? || custom_field.families.present?
  end

  def disable_action_on_custom_form(custom_field)
    custom_field.user.present? || custom_field.clients.present? || custom_field.partners.present? || custom_field.families.present? ? 'disabled' : ''
  end

  def field_with(field,errors)
    errors.has_key?(field.to_sym) ? 'has-error' : ''
  end

  def field_message(field, errors)
    errors[field.to_sym].join(', ') if errors[field.to_sym].present?
  end

  def display_custom_properties(value)
    date = Date.parse(value) rescue nil
    span = content_tag :span do
      if date
        concat date.strftime('%B %d, %Y')
      elsif value.is_a?(Array)
        value.reject{ |i| i.empty? }.each do |c|
          concat content_tag(:strong, c, class: 'label')
        end
      else
        concat value
      end
    end
    span
  end

  def custom_field_frequency(frequency, time_of_frequency)
    case frequency
    when 'Day' then time_of_frequency.day
    when 'Week' then time_of_frequency.week
    when 'Month' then time_of_frequency.month
    when 'Year' then time_of_frequency.year
    else 0.day
    end
  end
end
