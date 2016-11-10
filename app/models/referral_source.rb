class ReferralSource < ActiveRecord::Base
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
