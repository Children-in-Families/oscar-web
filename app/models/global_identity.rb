class GlobalIdentity < ActiveRecord::Base
  self.primary_key = "ulid"
  has_many :clients, class_name: 'Client', foreign_key: 'global_id', dependent: :restrict_with_error
  has_many :organizations, through: :global_identity_organizations
  has_many :global_identity_organizations, class_name: 'GlobalIdentityOrganization', foreign_key: 'global_id', dependent: :destroy
  has_many :external_system_global_identities, class_name: 'ExternalSystemGlobalIdentity', foreign_key: 'global_id', dependent: :destroy

  validates :ulid, presence: true, uniqueness: { case_sensitive: false }
end
