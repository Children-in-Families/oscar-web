class DonorFamily < ActiveRecord::Base
  has_paper_trail

  belongs_to :donor, required: true
  belongs_to :family, required: true

  validates :donor, :family, presence: true
end
