class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  mount_uploader :file, FileUploader

  belongs_to :progress_note

  validates_processing_of :image

  validate :image_size_validation

  protected

  def _filename
    file_name = File.basename(path).split('.').first.titleize
    extention = File.basename(path).split('.').last
    "#{file_name}.#{extention}"
  end

  private

  def image_size_validation
    errors[:image] << 'should be less than 1MB' if image.size > 1.megabytes
  end
end
