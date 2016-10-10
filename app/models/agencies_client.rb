class AgenciesClient < ActiveRecord::Base
  belongs_to :agency
  belongs_to :client, touch: true
  has_paper_trail
end