class AgencyClient < ActiveRecord::Base
  belongs_to :agency
  belongs_to :client

  has_paper_trail
end
