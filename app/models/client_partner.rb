class ClientPartner < ActiveRecord::Base
  belongs_to :client
  belongs_to :partner

  has_paper_trail
end
