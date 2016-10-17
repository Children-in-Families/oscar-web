class QuantitativeCase < ActiveRecord::Base
  validates :value, presence: true, uniqueness: true

  belongs_to :quantitative_type, counter_cache: true

  has_and_belongs_to_many :clients

  default_scope { order(value: :asc) }

  scope :value_like, -> (values) { where('LOWER(quantitative_cases.value) ILIKE ANY ( array[?] )', values.map { |val| "%#{val.downcase}%" }) }

  scope :quantitative_cases_by_type, -> (id) { where('quantitative_type_id = ?', id) }

end
