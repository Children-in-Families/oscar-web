module AttachmentHelper
  def original_filename(object)
    File.basename(object.file.path)
  end

  def original_filetype(object)
    object.file.content_type.split('/')
  end

  def preview_or_download(object)
    return t('.preview_download') if pdf?(object) || image?(object)
    t('.download')
  end

  private

  def pdf?(object)
    original_filetype(object).last == 'pdf'
  end

  def image?(object)
    original_filetype(object).first == 'image'
  end
end
