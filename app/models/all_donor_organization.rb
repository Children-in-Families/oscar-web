class AllDonorOrganization < ActiveRecord::Base
  belongs_to :all_donor
  belongs_to :organization
end
