module AttachmentFileHelper
  def file_name_from_file(file)
    file_name = File.basename(file.path).split('.').first.titleize
    extention = File.basename(file.path).split('.').last
    
    "#{file_name}.#{extention}"
  end
end
