class CustomFieldPropertyUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    'image-placeholder.png'
  end

  version :thumb, if: :image? do
    process resize_to_fill: [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg png doc docx xls xlsx pdf)
  end

  protected

  def image?(new_file)
    if new_file.content_type.present?
      new_file.content_type.start_with? 'image'
    end
  end
end
