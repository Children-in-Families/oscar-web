class AllDonor < ActiveRecord::Base
  has_many :all_donor_organizations, dependent: :destroy
  has_many :organizations, through: :all_donor_organizations

end
