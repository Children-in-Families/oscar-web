class QuantitativeType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :quantitative_cases

  default_scope { order(name: :asc) }
end
