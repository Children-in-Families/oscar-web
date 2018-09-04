class VillageSerializer < ActiveModel::Serializer
  attributes :id, :code, :code_format, :name

  def code_format
    object.code_format
  end

  def name
    object.name
  end
end
