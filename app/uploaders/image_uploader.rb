class ImageUploader < CarrierWave::Uploader::Base
  # include CarrierWave::RMagick
  # include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick
  include UploaderConcern

  process :auto_orient
  version :thumb do
    process resize_to_limit: [nil, 200]
    process quality: 100
  end

  version :photo do
    process resize_to_fit: [nil, 150]
    process quality: 100
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    'image-placeholder.png'
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def auto_orient
    manipulate! do |img|
      img = img.auto_orient
    end
  end
end
