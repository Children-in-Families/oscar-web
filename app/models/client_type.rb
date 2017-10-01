class ClientType < ActiveRecord::Base
  has_many :client_client_types, dependent: :restrict_with_error
  has_many :clients, through: :client_client_types
end
