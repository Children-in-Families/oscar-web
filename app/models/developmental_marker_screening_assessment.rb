class DevelopmentalMarkerScreeningAssessment < ActiveRecord::Base
  attr_accessor :_destroy
  belongs_to :screening_assessment
  belongs_to :developmental_marker

  validates :question_1, :question_2, :question_3, :question_4, inclusion: { in: [true, false] }
end
