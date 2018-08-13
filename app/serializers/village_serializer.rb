class VillageSerializer < ActiveModel::Serializer
  attributes :id, :code, :code_format

  def code_format
    object.code_format
  end
end
