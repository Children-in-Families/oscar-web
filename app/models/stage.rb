class Stage < ActiveRecord::Base

  MEASUREMENTS = %w(month year).freeze

  has_many :able_screening_questions, dependent: :destroy

  has_paper_trail

  validates :from_age, presence: true
  validates :to_age, presence: true, uniqueness: { scope: :from_age }, numericality: { greater_than: :from_age }

  accepts_nested_attributes_for :able_screening_questions, reject_if: :all_blank, allow_destroy: true

  before_save :check_question_mode

  def check_question_mode
    able_screening_questions.each do |question|
      question.alert_manager = false if question.free_text?
    end
  end

  def from_age_as_date
    (from_age * 12).to_i.months.ago.to_date.end_of_month
  end

  def to_age_as_date
    (to_age * 12).to_i.months.ago.to_date.beginning_of_month
  end
end
