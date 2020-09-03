class CustomAssessmentSetting < ActiveRecord::Base
  belongs_to :setting
  has_many   :domains, dependent: :destroy
  has_many   :case_notes, dependent: :restrict_with_error

  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 30, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'day' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 4, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'week' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 1, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'month' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 0, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'year' }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: :custom_age?

  validates :custom_assessment_name, presence: true, if: :enable_custom_assessment?
  validates :max_custom_assessment, presence: true, if: :enable_custom_assessment?
  validates :custom_age, presence: true, if: :enable_custom_assessment?

  scope :any_custom_assessment_enable?, -> { all.present? }
  scope :only_enable_custom_assessment, -> { where(enable_custom_assessment: true) }

  def max_assessment_duration
    max_custom_assessment.send(custom_assessment_frequency.to_sym)
  end
end
