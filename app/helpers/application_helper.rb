module ApplicationHelper
  Thredded::ApplicationHelper
  def color_class_for(score)
    case score
    when 1 then 'danger'
    when 2 then 'warning'
    when 3 then 'primary'
    when 4 then 'success'
    end
  end

  def status_style(status)
    color = 'label-success'
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

  def removeable?(object, associated_objects_count)
    if associated_objects_count.zero?
      link_to object, method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag(:i, '', class: 'glyphicon glyphicon-trash')
      end
    else
      content_tag(:i, '', class: 'glyphicon glyphicon-trash')
    end
  end

  def domain_removeable?(object, associated_objects_count)
    if associated_objects_count.zero? && object.assessment_domains.blank?
      link_to object, method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag(:i, '', class: 'glyphicon glyphicon-trash')
      end
    else
      content_tag(:i, '', class: 'glyphicon glyphicon-trash')
    end
  end

  def client_removeable?(object, associated_objects_count)
    if associated_objects_count[0].zero? && associated_objects_count[1].zero?
      link_to object, method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag(:i, '', class: 'glyphicon glyphicon-trash')
      end
    else
      content_tag(:i, '', class: 'glyphicon glyphicon-trash')
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
      if action_name == 'edit' || action_name == 'update'
        'active'
      else
        ''
      end
    end
  end

  def any_active_menu(names)
    name = controller_name
    if names.include? name
      'active'
    else
      ''
    end
  end

  def active_menu(name)
    if controller_name == name
      'active'
    else
      ''
    end
  end

  def user_dashboard(user)
    user.admin? || user.any_case_manager? ? 'col-md-6' : ''
  end

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
      'col-sm-6 col-md-3'
    elsif user.any_case_manager?
      'col-sm-4'
    elsif user.able_manager? || user.case_worker?
      'col-sm-6'
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
    if f.error_notification.present?
      content_tag(:div, t('review_problem'), class: 'alert alert-danger')
    end
  end

  def able_related_info(value)
    'able-related-info' if %w(illness, disability).any? { |w| value.include?(w) }
  end
end
