module CustomFormNotificationHelper
	def entity_custom_field_url(entity, custom_field)
		entity_custom_field = params[:entity_custom_field]
		if entity_custom_field == 'client_due_today' || entity_custom_field == 'client_overdue'
			link_to custom_field.form_title, client_client_custom_fields_path(entity, custom_field_id: custom_field.id)
		elsif entity_custom_field == 'user_due_today' || entity_custom_field == 'user_overdue'
			link_to custom_field.form_title, user_user_custom_fields_path(entity, custom_field_id: custom_field.id)
		elsif entity_custom_field == 'partner_due_today' || entity_custom_field == 'partner_overdue'
			link_to custom_field.form_title, partner_partner_custom_fields_path(entity, custom_field_id: custom_field.id)
		elsif entity_custom_field == 'family_due_today' || entity_custom_field == 'family_overdue'
			link_to custom_field.form_title, family_family_custom_fields_path(entity, custom_field_id: custom_field.id)
		end
	end

	def entity_title_custom_field
		entity_custom_field = params[:entity_custom_field]
		entity_type = '';
		if entity_custom_field == 'client_due_today' || entity_custom_field == 'client_overdue'
			entity_type = 'Client'
		elsif entity_custom_field == 'user_due_today' || entity_custom_field == 'user_overdue'
			entity_type = 'User'
		elsif entity_custom_field == 'partner_due_today' || entity_custom_field == 'partner_overdue'
			entity_type = 'Partner'
		elsif entity_custom_field == 'family_due_today' || entity_custom_field == 'family_overdue'
			entity_type = 'Family'
		end
	end
end
