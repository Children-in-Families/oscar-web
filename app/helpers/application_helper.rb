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

  def authorized_body
    'unauthorized-background' unless user_signed_in?
  end

  def status_style(status)
    color = 'label-primary'
    case status
    when 'Referred'
      color = 'label-danger'
    when 'Investigating'
      color = 'label-warning'
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
    names = %w(clients tasks assessments case_notes cases)
    any_active_menu names
  end

  def manage_menu_active
    names = %w(agencies departments domains domain_groups provinces referral_sources quantitative_types)
    any_active_menu names
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

  # def user_dashboard(user)
  #   user.admin? || user.any_case_manager? ? 'col-md-6' : ''
  # end

  def user_dashboard_responsive(user)
    user.admin? || user.case_worker? ? 'box-pusher' : 'col-xs-12 big-box'
  end

  def hidden_class(bool)
    'hidden' if bool
  end

  def exit_modal_class(bool)
    bool ? 'exitFromCif' : 'exitFromCase'
  end

  def dynamic_md_col(user)
    user.any_case_manager? ? 'col-md-12' : 'col-md-6'
  end

  def dynamic_third_party_cols(user)
    if user.admin?
      'col-xs-12'
    elsif user.any_case_manager?
      'col-xs-12'
    elsif user.able_manager?
      'col-sm-6'
    elsif user.case_worker?
      'col-sm-4'
    end
  end

  def custom_case_dashboard(user)
    if user.any_case_manager?
      'big-box'
    elsif user.admin? || user.case_worker?
      'top-spacing'
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

  def organization_name
    Organization.current.try(:full_name) || 'Cambodian Families'
  end

  def date_format(date)
    date.strftime('%d %B, %Y')
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

  def visitor?
    current_user.visitor?
  end
end
