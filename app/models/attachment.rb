class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :able_screening_question

  validates_processing_of :image
  validate :image_size_validation

  private
    def image_size_validation
      errors[:image] << "should be less than 1MB" if image.size > 1.megabytes
    end

end
