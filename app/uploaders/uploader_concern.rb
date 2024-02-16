module UploaderConcern
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
