class Agency < ApplicationRecord
  has_many :agency_clients
  has_many :clients, through: :agency_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.name_like(values = [])
    where('name iLIKE ANY ( array[?] )', values)
  end
end
