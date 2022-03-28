class CustomAssessmentSetting < ActiveRecord::Base
  belongs_to :setting
  has_many   :domains, dependent: :destroy
  has_many   :case_notes, dependent: :restrict_with_error

  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 30, if: -> { check_custom_assessment_frequency('day') }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 4, if: -> { check_custom_assessment_frequency('week') }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 1, if: -> { check_custom_assessment_frequency('month') }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 0, if: -> { check_custom_assessment_frequency('year') }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100

  validates :custom_assessment_name, presence: true, uniqueness: { case_sensitive: true }
  validates :max_custom_assessment, presence: true
  validates :custom_age, presence: true

  scope :any_custom_assessment_enable?, -> { all.any? }
  scope :only_enable_custom_assessment, -> { where(enable_custom_assessment: true) }

  after_commit :flush_cache

  def max_assessment_duration
    max_custom_assessment.send(custom_assessment_frequency.to_sym)
  end

  def check_custom_assessment_frequency(name_of_day)
    if self.custom_assessment_frequency == 'unlimited'
      self.max_custom_assessment = 0
      return false
    else
      self.enable_custom_assessment && self.max_custom_assessment.present? && self.custom_assessment_frequency == name_of_day
    end
  end

  def self.cache_custom_assessment
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomAssessmentSetting', 'enable_custom_assessment', 'true']) do
      only_enable_custom_assessment.to_a
    end
  end

  private

  def flush_cache
    Rails.cache.fetch([Apartment::Tenant.current, 'CustomAssessmentSetting', 'enable_custom_assessment', 'true']) if enable_custom_assessment
  end
end
