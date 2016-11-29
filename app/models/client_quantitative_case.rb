class ClientQuantitativeCase < ActiveRecord::Base
  belongs_to :client
  belongs_to :quantitative_case

  has_paper_trail
end
