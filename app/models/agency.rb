class Agency < ActiveRecord::Base
  has_and_belongs_to_many :clients
  has_paper_trail

  validates :name, presence: true, uniqueness: true

  def self.name_like(values = [])
    downcase_values = values.map { |val| "%#{val.downcase}%" }
    where('LOWER(agencies.name) ILIKE ANY ( array[?] )', downcase_values)
  end
end
