class QuantitativeCase < ActiveRecord::Base
  validates :value, presence: true, uniqueness: true

  belongs_to :quantitative_type, counter_cache: true

  has_and_belongs_to_many :clients

  default_scope { order(value: :asc) }
end
