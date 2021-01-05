class QuantitativeCase < ApplicationRecord
  validates :value, presence: true, uniqueness: { case_sensitive: false, scope: :quantitative_type_id }

  belongs_to :quantitative_type, counter_cache: true

  has_many :client_quantitative_cases
  has_many :clients, through: :client_quantitative_cases

  has_paper_trail

  default_scope { order(value: :asc) }

  scope :value_like, ->(values) { where('quantitative_cases.value iLIKE ANY ( array[?] )', values.map { |val| "%#{val}%" }) }

  scope :quantitative_cases_by_type, ->(id) { where('quantitative_type_id = ?', id) }
end
