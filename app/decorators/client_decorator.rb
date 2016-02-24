class ClientDecorator < Draper::Decorator
  delegate_all

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
