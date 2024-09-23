class DemoOrganizationSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :short_name, :logo, :country
end
