class AgencyClient < ApplicationRecord
  belongs_to :agency
  belongs_to :client

  has_paper_trail
end
