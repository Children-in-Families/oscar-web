class ConsentFormUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include UploaderConcern

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    'image-placeholder.png'
  end

  def extension_white_list
    %w(jpg jpeg png doc docx xls xlsx pdf)
  end

  def serializable_hash
    super.merge(
      filename: _filename
    )
  end

  protected

  def _filename
    return unless path

    file_name = File.basename(path).split('.').first.titleize
    extention = File.basename(path).split('.').last
    "#{file_name}.#{extention}"
  end
end
