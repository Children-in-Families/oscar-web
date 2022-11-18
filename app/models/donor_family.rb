class DonorFamily < ApplicationRecord
  has_paper_trail

  belongs_to :donor
  belongs_to :family

  validates :donor, :family, presence: true
end
