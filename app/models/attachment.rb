class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  mount_uploader :file, FileUploader

  belongs_to :progress_note

  validates_processing_of :image

  validate :image_size_validation

  private

  def image_size_validation
    errors[:image] << 'should be less than 1MB' if image.size > 1.megabytes
  end
end
