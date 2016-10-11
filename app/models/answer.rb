class Answer < ActiveRecord::Base
  belongs_to :able_screening_question
  belongs_to :client

  # validates :able_screening_question, :client, presence: true
  delegate :from_age_as_date, :to_age_as_date, :non_stage, :question, :has_image?, :first_image,
            to: :able_screening_question

  scope :of_general_question, -> { where(question_type: 'general') }
  scope :of_stage_question,   -> { where(question_type: 'stage') }

  def self.include_yes?
    where(description: 'Yes').any?
  end
end
