class Answer < ActiveRecord::Base
  belongs_to :able_screening_question
  belongs_to :client

  # validates :able_screening_question, :client, presence: true
  delegate :from_age_as_date, :to_age_as_date, :non_stage, :question, :has_image?, :first_image,
            to: :able_screening_question
end
