class SurveyDecorator < Draper::Decorator
  delegate_all

  def created_at
    object.created_at.strftime('%d %B %Y')
  end
end
