class DevelopmentalMarker < ActiveRecord::Base
  mount_uploader :question_1_illustation, ImageUploader
  mount_uploader :question_2_illustation, ImageUploader
  mount_uploader :question_3_illustation, ImageUploader
  mount_uploader :question_4_illustation, ImageUploader

  has_many :developmental_marker_screening_assessments, dependent: :destroy
  has_many :screening_assessments, through: :developmental_marker_screening_assessments

  default_scope { order(:id) }
end
