class ClientType < ActiveRecord::Base
  has_many :client_client_types, dependent: :restrict_with_error
  has_many :clients, through: :client_client_types

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
