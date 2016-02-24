class DomainSerializer < ActiveModel::Serializer
  attributes  :id, :name, :type, :description, :domain_group_id

  def type
    'domain'
  end
end
