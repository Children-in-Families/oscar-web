module ApplicationHelper
  Thredded::ApplicationHelper

  def flash_alert
    if notice
      { 'message-type': 'notice', 'message': notice }
    elsif alert
      { 'message-type': 'alert', 'message': alert }
    else
      {}
    end
  end

  def notification_client_exit(day)
    if day == 90
      t('.client_is_end_ec_today', count: @notification.ec_notification(day).count)
    else
      t('.client_is_about_to_end_ec', count: @notification.ec_notification(day).count, day_count: 90 - day)
    end
  end

  def authorized_body
    'unauthorized-background' unless user_signed_in?
  end

  def status_style(status)
    case status
    when 'Active' then color = 'label-primary'
    when 'Referred', 'Exited' then color = 'label-danger'
    when 'Accepted' then color = 'label-info'
    end

    content_tag(:span, class: ['label', color]) do
      status
    end
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def current_url(new_params)
    url_for params: params.merge(new_params)
  end

  def remove_link(object, associated_objects = {}, btn_size = 'btn-xs')
    btn_status = associated_objects.values.sum.zero? ? nil : 'disabled'
    link_to(object, method: 'delete',  data: { confirm: t('.are_you_sure') }, class: "btn btn-outline btn-danger #{btn_size} #{btn_status}") do
      fa_icon('trash')
    end
  end

  def clients_menu_active
    names = %w(clients tasks assessments case_notes cases government_reports leave_programs client_enrollments client_enrollment_trackings client_advanced_searches client_enrolled_programs client_enrolled_program_trackings leave_enrolled_programs)
    if names.include?(controller_name) && params[:family_id].nil?
      'active'
    elsif controller_name == 'custom_field_properties' && params[:client_id].present?
      'active'
    end
  end

  def families_menu_active
    names = %w(families cases)
    if names.include?(controller_name) && params[:client_id].nil?
      'active'
    elsif controller_name == 'custom_field_properties' && params[:family_id].present?
      'active'
    end
  end

  def users_menu_active
    if controller_name == 'users'
      'active'
    elsif controller_name == 'custom_field_properties' && params[:user_id].present?
      'active'
    end
  end

  def exit_circumstance_value
    # return @client.exit_circumstance if @client.exit_circumstance.present?
    @client.status == 'Accepted' ? 'Exited Client' : 'Rejected Referral'
  end

  def partners_menu_active
    if controller_name == 'partners'
      'active'
    elsif controller_name == 'custom_field_properties' && params[:partner_id].present?
      'active'
    end
  end

  def account_menu_active
    if :devise_controller? && params[:id].blank?
      'active' if action_name == 'edit' || action_name == 'update'
      ''
    end
  end

  def any_active_menu(names)
    'active' if names.include? controller_name
  end

  def active_menu(name, alter_name = '')
    controller_name == name || controller_name == alter_name ? 'active' : nil
  end

  def settings_menu_active(name, action_names)
    action = ['index' ,'update' ,'create'].include?(action_name) ? 'index' : action_name
    'active' if (controller_name == name && action_names == action)
  end

  def hidden_class(bool)
    'hidden' if bool
  end

  def exit_modal_class(bool)
    bool ? 'exitFromCif' : 'exitFromCase'
  end

  def dynamic_third_party_cols(user)
    if user.admin? || user.strategic_overviewer?
      'col-xs-12'
    elsif user.any_case_manager?
      'col-xs-12'
    elsif user.case_worker?
      'col-sm-4'
    end
  end

  def error_notification(f)
    content_tag(:div, t('review_problem'), class: 'alert alert-danger') if f.error_notification.present?
  end

  def able_related_info(value)
    'able-related-info' if %w(illness disability).any? { |w| value.include?(w) }
  end

  def clients_controller?
    controller_name == 'clients'
  end

  def date_format(date)
    date.strftime('%d %B, %Y') if date.present?
  end

  def date_time_format(date_time)
    date_time.in_time_zone('Bangkok').strftime('%d %B, %Y %H:%M:%S')
  end

  def ability_to_write(object)
    'disabled' if cannot? :write, object
  end

  def ability_to_update(object)
    'disabled' if cannot? :update, object
  end

  def ability_to_delete(object)
    'disabled' if cannot? :delete, object
  end

  def required?(bool)
    'required' if bool
  end

  def strategic_overviewer?
    current_user.strategic_overviewer?
  end

  def entity_name(entity)
    entity.name
  end

  def progarm_stream_action
    ['show', 'report']
  end

  def error_message(controller_name, field_message = '')
    if %(client_enrollments leave_programs client_enrollment_trackings).include?(controller_name)
      content_tag(:span, t('cannot_be_blank'), class: 'help-block hidden', data: { email: I18n.t('client_enrollments.form.not_an_email') })
    else
      content_tag(:span, field_message, class: 'help-block')
    end
  end

  def government_reports_visible?
    # current_organization.cwd? || current_organization.cif?
    false
  end

  def program_stream_readable?(value)
    return true if current_user.admin? || current_user.strategic_overviewer?
    current_user.program_stream_permissions.find_by(program_stream_id: value).readable
  end

  def program_permission_editable?(value)
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.program_stream_permissions.find_by(program_stream_id: value).editable
  end

  def custom_field_editable?(value)
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.custom_field_permissions.find_by(custom_field_id: value).editable
  end

  def non_mho_tenant?
    !current_organization.mho?
  end

  def action_search?
    Rails.application.routes.recognize_path(request.referrer)[:action] == 'search'
  end

  def convert_bracket(value)
    value.gsub(/\[/, '&#91;').gsub(/\]/, '&#93;')
  end

  def default_setting(column, setting_default_columns)
    key_columns = params.keys.select{ |k| k.match(/\_$/) }
    return false if setting_default_columns.nil? || (key_columns.present? && key_columns.exclude?(column))
    return false unless params.dig(:client_grid, :descending).present? || (params[:client_advanced_search].present? && params.dig(:client_grid, :descending).present?) || params[:client_grid].nil? || params[:client_advanced_search].nil?
    return false unless params.dig(:family_grid, :descending).present? || (params[:family_advanced_search].present? && params.dig(:family_grid, :descending).present?) || params[:family_grid].nil? || params[:family_advanced_search].nil?
    return false unless params.dig(:partner_grid, :descending).present? || (params[:partner_advanced_search].present? && params.dig(:partner_grid, :descending).present?) || params[:partner_grid].nil? || params[:partner_advanced_search].nil?
    setting_default_columns.include?(column.to_s)
  end
end
