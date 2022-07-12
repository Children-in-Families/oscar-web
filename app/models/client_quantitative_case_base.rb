class ClientQuantitativeCaseBase < ActiveRecord::Base
  self.table_name = 'client_quantitative_cases'

  belongs_to :client
  has_paper_trail
end
