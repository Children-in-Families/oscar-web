class NotificationController < AdminController
	def index
		entity_custom_field = params[:entity_custom_field]
		case entity_custom_field
		when 'client_due_today' 	then  @entity_custon_field_notifcation = @notification.client_custom_field_frequency_due_today
		when 'client_overdue' 		then  @entity_custon_field_notifcation = @notification.client_custom_field_frequency_overdue
		when 'user_due_today' 		then  @entity_custon_field_notifcation = @notification.user_custom_field_frequency_due_today
		when 'user_overdue' 			then  @entity_custon_field_notifcation = @notification.user_custom_field_frequency_overdue
		when 'partner_due_today'	then  @entity_custon_field_notifcation = @notification.partner_custom_field_frequency_due_today
		when 'partner_overdue' 		then  @entity_custon_field_notifcation = @notification.partner_custom_field_frequency_overdue
		when 'family_due_today' 	then  @entity_custon_field_notifcation = @notification.family_custom_field_frequency_due_today
		when 'family_overdue' 		then  @entity_custon_field_notifcation = @notification.family_custom_field_frequency_overdue
		end
	end
end
