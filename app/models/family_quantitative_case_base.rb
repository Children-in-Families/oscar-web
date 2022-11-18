class FamilyQuantitativeCaseBase < ApplicationRecord
  self.table_name = 'family_quantitative_cases'

  belongs_to :family
  has_paper_trail
end
