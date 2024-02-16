class ScreeningAssessmentSerializer < ActiveModel::Serializer
  attributes :id, :screening_assessment_date, :client_age, :visitor, :client_milestone_age,
             :attachments, :note, :smile_back_during_interaction, :follow_object_passed_midline,
             :turn_head_to_sound, :head_up_45_degree, :client_id, :screening_type

  has_many :developmental_marker_screening_assessments
  has_many :tasks
end
