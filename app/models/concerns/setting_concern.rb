module SettingConcern
  extend ActiveSupport::Concern

  included do
    validates_numericality_of :max_assessment, only_integer: true, greater_than: 30, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'day' }
    validates_numericality_of :max_assessment, only_integer: true, greater_than: 4, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'week' }
    validates_numericality_of :max_assessment, only_integer: true, greater_than: 1, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'month' }
    validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'year' }
  end

  class_methods do ; end

  def instance_method ; end
end
