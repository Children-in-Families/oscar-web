class DistrictSerializer < ActiveModel::Serializer
  attributes :id, :name, :code

  def province
    object.province
  end
end
