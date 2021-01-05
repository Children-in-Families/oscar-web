class Sponsor < ApplicationRecord
  has_paper_trail

  belongs_to :donor
  belongs_to :client
end
