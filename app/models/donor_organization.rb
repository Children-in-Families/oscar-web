class DonorOrganization < ActiveRecord::Base
  belongs_to :donor
  belongs_to :organization
end
