class CommuneSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :district_type, :district_id

  def name
    object.name
  end
end
