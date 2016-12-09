class ImageUploader < CarrierWave::Uploader::Base
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    'image-placeholder.png'
  end

  version :thumb do
    process :resize_to_fill => [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
