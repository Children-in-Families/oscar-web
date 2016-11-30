class Agency < ActiveRecord::Base
  # has_and_belongs_to_many :clients
  has_many :agency_clients
  has_many :clients, through: :agency_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.name_like(values = [])
    downcase_values = values.map { |val| "%#{val.downcase}%" }
    where('LOWER(agencies.name) ILIKE ANY ( array[?] )', downcase_values)
  end
end
