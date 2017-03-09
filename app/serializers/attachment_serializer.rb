class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :file, :created_at, :updated_at, :size, :name

  def size
    file.size
  end

  def name
    file.file.filename
  end
end
