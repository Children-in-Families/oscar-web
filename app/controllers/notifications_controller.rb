class NotificationsController < AdminController
  def index
    entity_custom_field = params[:entity_custom_field]
    @entity_custon_field_notifcation =  case entity_custom_field
    when 'client_due_today'   then  @notification.client_custom_field_frequency_due_today
    when 'client_overdue'     then  @notification.client_custom_field_frequency_overdue
    when 'user_due_today'     then  @notification.user_custom_field_frequency_due_today
    when 'user_overdue'       then  @notification.user_custom_field_frequency_overdue
    when 'partner_due_today'  then  @notification.partner_custom_field_frequency_due_today
    when 'partner_overdue'    then  @notification.partner_custom_field_frequency_overdue
    when 'family_due_today'   then  @notification.family_custom_field_frequency_due_today
    when 'family_overdue'     then  @notification.family_custom_field_frequency_overdue
    end
  end
end
