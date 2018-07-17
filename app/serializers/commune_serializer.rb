class CommuneSerializer < ActiveModel::Serializer
  attributes :id, :name, :code

  def name
    object.name
  end
end
