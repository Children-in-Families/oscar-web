class DevelopmentalMarker < ActiveRecord::Base
  mount_uploader :question_1_illustation, ImageUploader
  mount_uploader :question_2_illustation, ImageUploader
  mount_uploader :question_3_illustation, ImageUploader
  mount_uploader :question_4_illustation, ImageUploader

  has_many :developmental_marker_screening_assessments, dependent: :destroy
  has_many :screening_assessments, through: :developmental_marker_screening_assessments

  default_scope { order(:id) }

  def self.map_milestone_age_name
    all.pluck(:name).map do |name_en|
      if I18n.locale == :km
        local_name = I18n.t("datetime.dotiw.#{name_en[/[a-zA-Z]+/].pluralize}", count: name_en[/(\d\.\d)|\d/])
      else
        local_name = name_en
      end

      [local_name, name_en]
    end
  end
end
