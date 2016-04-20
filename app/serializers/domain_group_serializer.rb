class DomainGroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  has_many :domains
end
