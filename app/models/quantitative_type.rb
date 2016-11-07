class QuantitativeType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :quantitative_cases

  has_paper_trail

  default_scope { order(name: :asc) }

  accepts_nested_attributes_for :quantitative_cases, reject_if: :all_blank, allow_destroy: true

  scope :name_like, -> (name) { where('LOWER(quantitative_types.name) LIKE ?', "%#{name.downcase}%") }
end
