class DistrictSerializer < ActiveModel::Serializer
  attributes :id, :name, :province

  def province
    object.province
  end
end
