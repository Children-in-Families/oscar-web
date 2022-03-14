class ScreeningAssessment < ActiveRecord::Base
  mount_uploaders :attachments, FileUploader
  belongs_to :client

  has_many :developmental_marker_screening_assessments, dependent: :destroy
  has_many :developmental_markers, through: :developmental_marker_screening_assessments

  enum screening_type: { one_off: 'one_off', multiple: 'multiple' }
  validates :screening_assessment_date, :visitor, :client_milestone_age, presence: :true
  validates :smile_back_during_interaction, :follow_object_passed_midline,
            :turn_head_to_sound, :head_up_45_degree, inclusion: { in: [true, false] }

  scope :multiple_screening_assessments, -> { where(screening_type: 'multiple') }
end
