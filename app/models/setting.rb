class Setting < ActiveRecord::Base
  has_paper_trail

  belongs_to :province
  belongs_to :district
  # validates_numericality_of :min_assessment, only_integer: true, greater_than: 0, if: -> { min_assessment.present? }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 3, if: -> { max_assessment.present? && assessment_frequency == 'month' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { max_assessment.present? && assessment_frequency == 'year' }
  validates_numericality_of :max_case_note, only_integer: true, greater_than: 0, if: -> { max_case_note.present? }
  # validates_numericality_of :min_assessment, less_than: :max_assessment, if: -> { max_assessment.present? && min_assessment.present?}
  # validates_numericality_of :max_assessment, greater_than: :min_assessment, if: -> { max_assessment.present? && min_assessment.present?}
  validates :max_case_note, presence: true, if: -> { case_note_frequency.present? }
  # validates :min_assessment, :max_assessment, presence: true, if: -> { assessment_frequency.present? }
  validates :max_assessment, presence: true, if: -> { assessment_frequency.present? }
end
