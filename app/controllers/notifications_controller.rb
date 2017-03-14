class NotificationsController < AdminController
  def index
    entity_custom_field = params[:entity_custom_field]
    entity_custom_field_notification(entity_custom_field)
    if entity_custom_field == 'client_due_today' || entity_custom_field == 'user_due_today' || entity_custom_field == 'partner_due_today' || entity_custom_field == 'family_due_today'
      render 'custom_field_due_today'
    else
      render 'custom_field_overdue'
    end
  end

  private

  def entity_custom_field_notification(entity_custom_field)
    @entity_custom_field_notifcation =  case entity_custom_field
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
