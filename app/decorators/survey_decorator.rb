class SurveyDecorator < Draper::Decorator
  delegate_all

  def created_at
    object.created_at.strftime('%B %d, %Y')
  end
end
