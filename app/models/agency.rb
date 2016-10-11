class Agency < ActiveRecord::Base
  has_many :agencies_clients, dependent: :destroy
  has_many :clients, through: :agencies_clients
  has_paper_trail

  validates :name, presence: true, uniqueness: true

  scope :name_like, -> (values) { where('LOWER(agencies.name) ILIKE ANY ( array[?] )', values.map { |val| "%#{val.downcase}%" }) }
end
