class EnterNgoUser < ApplicationRecord
  belongs_to :enter_ngo
  belongs_to :user

  has_paper_trail
end
