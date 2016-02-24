module ApplicationHelper
  def color_class_for(score)
    case score
    when 1 then 'danger'
    when 2 then 'warning'
    when 3 then 'primary'
    when 4 then 'success'
    end
  end

  def status_style(status)
    color = 'text-success'

    case status
    when 'Referred'
      color = 'text-danger'
    when 'Investigating'
      color = 'text-warning'
    end

    content_tag(:span, class: color) do
      status
    end
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def current_url(new_params)
    url_for params: params.merge(new_params)
  end

  def removeable? object, associated_objects_count
    if associated_objects_count.zero?
      link_to object, method: 'delete', data: { confirm: 'Are you sure you want to delete?' } do
        content_tag(:i, '', class: 'glyphicon glyphicon-trash')
      end
    else
      content_tag(:i, '', class: 'glyphicon glyphicon-trash')
    end
  end

  def clients_menu_active
    names = ['clients','tasks','assessments','case_notes','cases']
    any_active_menu names
  end

  def manage_menu_active
    names = ['agencies','departments','domains','domain_groups','provinces','referral_sources','quantitative_types']
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

  def any_active_menu names
    name  = controller_name
    if names.include? name
      'active'
    else
      ''
    end
  end

  def active_menu name
    if controller_name == name
      'active'
    else
      ''
    end
  end

end
