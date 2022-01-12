module AttachmentHelper
  def original_filename(object)
    file_name = File.basename(object.file.path).split('.').first.titleize
    extention = File.basename(object.file.path).split('.').last
    "#{file_name}.#{extention}"
  end

  def original_filetype(object)
    object.file.content_type && object.file.content_type.split('/')
  end

  def preview_or_download(object)
    return t('shared.form_builder.list_attachment.preview_download') if pdf?(object) || image?(object)
    t('.download')
  end

  def target_blank(object)
    return '_blank' if pdf?(object) || image?(object)
  end

  def file_dir_or_symlink_exists?(path_to_file)
    File.exist?(path_to_file) || File.symlink?(path_to_file) || asset_exist?(path_to_file)
  end

  private

  def pdf?(object)
    original_filetype(object) && original_filetype(object).last == 'pdf'
  end

  def image?(object)
    original_filetype(object) && original_filetype(object).first == 'image'
  end
end
