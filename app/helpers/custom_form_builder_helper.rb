module CustomFormBuilderHelper
	def used_custom_form?
		@custom_field.user.present? || @custom_field.clients.present? || @custom_field.partners.present? || @custom_field.families.present?
	end
end
