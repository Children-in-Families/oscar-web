class CommunityDonor < ActiveRecord::Base
  has_paper_trail

  belongs_to :donor
  belongs_to :community

  validates :donor, :family, presence: true
end
