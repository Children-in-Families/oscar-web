module ScreeningAssessmentHelper
  def field_to_local(object, field_name)
    if I18n.locale == :km
      object.public_send("#{field_name}_local")
    else
      object.public_send(field_name)
    end
  end
end