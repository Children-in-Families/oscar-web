class DonorOrganization < ApplicationRecord
  belongs_to :donor
  belongs_to :organization
end
