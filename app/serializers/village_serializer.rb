class VillageSerializer < ActiveModel::Serializer
  attributes :id, :code, :code_format, :name, :commune_id
end
