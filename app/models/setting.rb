class Setting < ActiveRecord::Base
  has_paper_trail

  belongs_to :province
  belongs_to :district
  belongs_to :commune

  validates_numericality_of :max_assessment, only_integer: true, greater_than: 3, if: -> { max_assessment.present? && assessment_frequency == 'month' }
  validates_numericality_of :max_assessment, only_integer: true, greater_than: 0, if: -> { max_assessment.present? && assessment_frequency == 'year' }
  validates_numericality_of :max_case_note, only_integer: true, greater_than: 0, if: -> { max_case_note.present? }
  validates_numericality_of :age, only_integer: true, greater_than: 0, less_than_or_equal_to: 100, if: -> { age.present? }
  validates :max_case_note, presence: true, if: -> { case_note_frequency.present? }
  validates :max_assessment, presence: true, if: -> { assessment_frequency.present? }

  delegate :name, to: :province, prefix: true, allow_nil: true
  delegate :name, to: :district, prefix: true, allow_nil: true
end
