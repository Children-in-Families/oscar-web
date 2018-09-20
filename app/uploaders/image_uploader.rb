class ImageUploader < CarrierWave::Uploader::Base
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  version :thumb do
    process resize_to_limit: [nil, 200]
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
end
