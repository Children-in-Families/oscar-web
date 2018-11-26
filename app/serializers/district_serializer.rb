class DistrictSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :province_id

  def province
    object.province
  end
end
