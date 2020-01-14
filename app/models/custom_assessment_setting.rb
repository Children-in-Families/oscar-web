class CustomAssessmentSetting < ActiveRecord::Base
  belongs_to :setting
  has_many   :domains

  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 3, if: -> { Setting.first.enable_custom_assessment.present? && Setting.first.max_custom_assessment.present? && Setting.first.custom_assessment_frequency == 'month' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 0, if: -> { Setting.first.enable_custom_assessment.present? && Setting.first.max_custom_assessment.present? && Setting.first.custom_assessment_frequency == 'year' }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { Setting.first.age.present? }

  validates :custom_assessment_name, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }
  validates :max_custom_assessment, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }
  validates :custom_age, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }
end
