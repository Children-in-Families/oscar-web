module EntityTypeCustomFieldHelper
	def next_entity_type_custom_field(entity_type_custom_fields, entity, custom_field)
		last_custom_field_date = entity_type_custom_fields.last.created_at.to_date
		time_of_frequency 		 = custom_field_frequency(custom_field.frequency, custom_field.time_of_frequency)
		next_custom_field_date = last_custom_field_date + time_of_frequency
		if next_custom_field_date <= Date.today
			controller = "#{entity.class.to_s.underscore}_custom_fields"
			link_to controller: controller, action: 'new', custom_field_id: params[:custom_field_id] do
        content_tag(:span, "#{t('.add_new')} #{custom_field.form_title}", class: "btn btn-outline btn-primary button form-btn")
      end
		else
			content_tag(:span, "#{t('.add_new')} #{custom_field.form_title}", class: "btn btn-outline btn-primary button form-btn disabled")
		end
	end
end
