class CaseClosure < ApplicationRecord
  has_paper_trail

  has_many :government_forms

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
