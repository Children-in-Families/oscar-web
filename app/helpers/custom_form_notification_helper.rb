module CustomFormNotificationHelper
  def entity_custom_field_url(entity, custom_field)
    entity_custom_field = params[:entity_custom_field]
    link_to custom_field.form_title, polymorphic_url([entity, CustomFieldProperty], custom_field_id: custom_field.id)
  end

  def entity_title_custom_field
    entity_custom_field = params[:entity_custom_field]
    entity_type = '';
    if entity_custom_field == 'client_due_today' || entity_custom_field == 'client_overdue'
      entity_type = t('.clients')
    elsif entity_custom_field == 'user_due_today' || entity_custom_field == 'user_overdue'
      entity_type = t('.users')
    elsif entity_custom_field == 'partner_due_today' || entity_custom_field == 'partner_overdue'
      entity_type = t('.partners')
    elsif entity_custom_field == 'family_due_today' || entity_custom_field == 'family_overdue'
      entity_type = t('.families')
    end
  end
end
