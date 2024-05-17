class AssessmentDecorator < Draper::Decorator
  delegate_all

  def completed_label_class
    model.completed? ? 'label label-primary' : 'label label-danger'
  end

  def completed_status
    model.completed? ? I18n.t('assessments.complete') : I18n.t('assessments.incomplete')
  end
end
