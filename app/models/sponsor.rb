class Sponsor < ActiveRecord::Base
  has_paper_trail

  belongs_to :donor
  belongs_to :client
end
