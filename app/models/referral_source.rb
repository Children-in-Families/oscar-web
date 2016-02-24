class ReferralSource < ActiveRecord::Base
  has_many :emergency_case_clients

  validates :name, presence: true, uniqueness: true
end
