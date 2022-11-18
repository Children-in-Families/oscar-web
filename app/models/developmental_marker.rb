class DevelopmentalMarker < ApplicationRecord
  mount_uploader :question_1_illustation, ImageUploader
  mount_uploader :question_2_illustation, ImageUploader
  mount_uploader :question_3_illustation, ImageUploader
  mount_uploader :question_4_illustation, ImageUploader

  has_many :developmental_marker_screening_assessments, dependent: :destroy
  has_many :screening_assessments, through: :developmental_marker_screening_assessments

  default_scope { order(:id) }

  def self.map_milestone_age_name
    all.pluck(:name, :name_local).map do |name_en, name_local|
      if I18n.locale == :km
        name = name_local
      else
        name = name_en
      end

      [name, name_en]
    end
  end
end
