class Agency < ActiveRecord::Base
  has_and_belongs_to_many :clients

  validates :name, presence: true, uniqueness: true

  scope :name_like, -> (values) { where('LOWER(agencies.name) ILIKE ANY ( array[?] )', values.map { |val| "%#{val.downcase}%" }) }
end
