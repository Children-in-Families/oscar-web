class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  process :set_content_type
  
  def filename
    "#{secure_token}_original_#{original_filename}" if original_filename
  end


  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    'image-placeholder.png'
  end

  version :thumb, if: :image? do
    process resize_to_fill: [100, 100]
  end

  version :dropzonethumb, if: :image? do
    process resize_to_fill: [120, 120]
  end

  def extension_white_list
    %w(jpg jpeg png doc docx xls xlsx pdf)
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def image?(new_file)
    new_file.content_type.start_with? 'image'
  end
end
