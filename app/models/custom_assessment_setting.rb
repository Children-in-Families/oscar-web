class CustomAssessmentSetting < ActiveRecord::Base
  belongs_to :setting
  has_many   :domains, dependent: :destroy
  has_many   :case_notes, dependent: :restrict_with_error

  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 3, if: -> { Setting.first.enable_custom_assessment.present? && Setting.first.max_custom_assessment.present? && Setting.first.custom_assessment_frequency == 'month' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 0, if: -> { Setting.first.enable_custom_assessment.present? && Setting.first.max_custom_assessment.present? && Setting.first.custom_assessment_frequency == 'year' }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { Setting.first.age.present? }

  validates :custom_assessment_name, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }
  validates :max_custom_assessment, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }
  validates :custom_age, presence: true, if: -> { Setting.first.enable_custom_assessment.present? }

  scope :any_custom_assessment_enable?, -> { all.present? }
  scope :only_enable_custom_assessment, -> { where(enable_custom_assessment: true) }
end
