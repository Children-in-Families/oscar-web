class DomainGroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :domain_descriptions, :description

  def type
    'domain_group'
  end

  def domain_descriptions
    object.domain_descriptions
  end
end
