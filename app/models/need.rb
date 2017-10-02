class Need < ActiveRecord::Base
  has_many :client_needs, dependent: :restrict_with_error
  has_many :clients, through: :client_needs

  # accepts_nested_attributes_for :client_needs
end
