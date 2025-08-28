module CustomFormBuilderHelper
  def used_custom_form?(custom_field)
    custom_field.custom_field_properties.present?
  end

  def disable_action_on_custom_form(custom_field)
    used_custom_form?(custom_field) ? 'disabled' : ''
  end

  def field_with(field, errors)
    errors.has_key?(field.to_sym) ? 'has-error' : ''
  end

  def field_message(field, errors)
    errors[field.to_sym].join(', ') if errors[field.to_sym].present?
  end

  def display_custom_properties(value, type = nil)
    div = content_tag :div do
      if value =~ /(\d{4}[-\/]\d{1,2}[-\/]\d{1,2})/
        concat value.to_date.strftime('%d %B %Y')
      elsif value.is_a?(Array)
        return value.join(', ') if type == 'select' || type == 'checkbox-group'
        value.reject { |i| i.empty? }.each do |c|
          concat content_tag(:strong, c.gsub('&amp;qoute;', '&quot;').html_safe, class: 'label label-margin')
        end
      elsif value.is_a?(Hash)
        display_custom_properties(value.values.flatten)
      else
        concat value.gsub('&amp;qoute;', '&quot;').html_safe if value.present?
      end
    end
    content = div.gsub('&amp;nbsp;', '')
    content = content.gsub("\n", '<br />')
    content = content.gsub('&lt;', '<')
    content = content.gsub('&gt;', '>')
    content.html_safe
  end

  def custom_field_frequency(frequency, time_of_frequency)
    case frequency
    when 'Daily' then time_of_frequency.day
    when 'Weekly' then time_of_frequency.week
    when 'Monthly' then time_of_frequency.month
    when 'Yearly' then time_of_frequency.year
    else 0.day
    end
  end

  def frequency_note(custom_field)
    return if custom_field.frequency.empty?
    frequency = case custom_field.frequency
                when 'Daily' then 'day'
                when 'Weekly' then 'week'
                when 'Monthly' then 'month'
                when 'Yearly' then 'year'
                else
                  'year'
                end

    if custom_field.time_of_frequency == 1
      "This needs to be done once every #{frequency}."
    elsif custom_field.time_of_frequency > 1
      "This needs to be done once every #{pluralize(custom_field.time_of_frequency, frequency)}."
    else
      'This can be done many times and anytime.'
    end
  end

  def allowed_edit_until_options
    [
      ['24 Hours', '24.hours'], ['48 Hours', '48.hours'],
      ['1 Week', '1.week'], ['1 Month', '1.month'],
      ['3 Months', '3.months'], ['6 Months', '6.months'], ['1 Year', '1.year']
    ]
  end
end
