class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :short_name, :logo, :country, :demo
end
