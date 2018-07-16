class FamilyMember < ActiveRecord::Base
  belongs_to :family

  has_paper_trail
end
