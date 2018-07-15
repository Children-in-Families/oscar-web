class VillageSerializer < ActiveModel::Serializer
  attributes :id, :code, :code_format

  def code_format
    "#{object.name_kh} / #{object.name_en} (#{object.code})"
  end
end
