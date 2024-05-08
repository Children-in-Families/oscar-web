class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :parent_id
end
