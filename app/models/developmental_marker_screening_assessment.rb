class DevelopmentalMarkerScreeningAssessment < ActiveRecord::Base
  belongs_to :screening_assessment
  belongs_to :developmental_marker
end
