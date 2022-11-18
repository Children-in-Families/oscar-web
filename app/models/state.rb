class State < ApplicationRecord
  include AddressConcern

  has_many :townships
  has_many :clients, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
