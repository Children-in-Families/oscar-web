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
end
