class ClientDecorator < Draper::Decorator
  delegate_all

  def care_code
    model.code.present? ? model.code : ''
  end

  def can_add_ec?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.ec_manager?
  end

  def can_add_fc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.fc_manager?
  end

  def can_add_kc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.kc_manager?
  end

  def status
    color = 'text-success'

    case model.status
    when 'Referred'
      color = 'text-danger'
    when 'Investigating'
      color = 'text-warning'
    end

    h.content_tag(:span, class: color) do
      model.status
    end
  end
end
