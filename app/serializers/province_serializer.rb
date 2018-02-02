class ProvinceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :districts

  def districts
    object.districts.order(:name)
  end
end
