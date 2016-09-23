class Answer < ActiveRecord::Base
  belongs_to :able_screening_question
  belongs_to :client

  # validates :able_screening_question, :client, presence: true
end
