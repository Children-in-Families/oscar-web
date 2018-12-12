class VillageSerializer < ActiveModel::Serializer
  attributes :id, :code, :code_format, :name, :commune_id

  def code_format
    object.code_format
  end

  def name
    object.name
  end
end
