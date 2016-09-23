class Stage < ActiveRecord::Base

  MEASUREMENTS = %w(month year).freeze

  has_many :able_screening_questions, dependent: :destroy

  # validates :from_age, :to_age, presence: true

  accepts_nested_attributes_for :able_screening_questions, reject_if: :all_blank, allow_destroy: true
end
