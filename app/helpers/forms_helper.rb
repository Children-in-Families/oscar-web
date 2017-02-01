module FormsHelper
  def radio_button_color(radio)
    radio_button_class = ''

    case radio.object.first
    when 1
      radio_button_class = 'i-check-brown'
    when 2
      radio_button_class = 'i-check-red'
    when 3
      radio_button_class = 'i-check-orange'
    when 4
      radio_button_class = 'i-checks'
    end

    radio.radio_button(class: radio_button_class) + radio.label
  end
end
