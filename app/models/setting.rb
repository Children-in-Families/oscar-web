class Setting < ActiveRecord::Base
  has_paper_trail

  belongs_to :province
  belongs_to :district
  belongs_to :commune

  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 3, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'month' }
  validates_numericality_of :max_custom_assessment, only_integer: true, greater_than: 0, if: -> { enable_custom_assessment.present? && max_custom_assessment.present? && custom_assessment_frequency == 'year' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 3, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'month' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { enable_default_assessment.present? && max_assessment.present? && assessment_frequency == 'year' }
  validates_numericality_of :max_case_note, only_integer: true, greater_than: 0, if: -> { max_case_note.present? }
  validates_numericality_of :age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { age.present? }
  validates_numericality_of :custom_age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { age.present? }

  validates :max_case_note, presence: true, if: -> { case_note_frequency.present? }
  validates :default_assessment, presence: true, if: -> { enable_default_assessment.present? }
  validates :max_assessment, presence: true, if: -> { enable_default_assessment.present? }
  validates :age, presence: true, if: -> { enable_default_assessment.present? }
  validates :assessment_frequency, presence: true, if: -> { enable_default_assessment.present? }
  validate  :custom_assessment_name, if: -> { enable_custom_assessment.present? }
  validates :custom_assessment_frequency, presence: true, if: -> { enable_custom_assessment.present? }
  validates :max_custom_assessment, presence: true, if: -> { enable_custom_assessment.present? }
  validates :custom_age, presence: true, if: -> { enable_custom_assessment.present? }

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true

  private

  def custom_assessment_name
    errors.add(:custom_assessment, I18n.t('invalid_name')) if custom_assessment.downcase.include?('csi')
  end
end
