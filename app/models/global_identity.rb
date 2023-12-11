class GlobalIdentity < ActiveRecord::Base
  self.primary_key = "ulid"
  has_many :clients, class_name: 'Client', foreign_key: 'global_id', dependent: :restrict_with_error
  has_many :organizations, through: :global_identity_organizations
  has_many :global_identity_organizations, class_name: 'GlobalIdentityOrganization', foreign_key: 'global_id', dependent: :destroy
  has_many :external_system_global_identities, class_name: 'ExternalSystemGlobalIdentity', foreign_key: 'global_id', dependent: :destroy

  validates :ulid, presence: true, uniqueness: { case_sensitive: false }

  after_commit :create_external_system_global_identity

  def self.find_or_initialize_ulid(client_global_id)
    begin
      GlobalIdentity.find(client_global_id).try(:ulid)
    rescue ActiveRecord::RecordNotFound
      GlobalIdentity.new(ulid: ULID.generate).ulid
    end
  end

  private

  def create_external_system_global_identity
    client = Client.find_by(global_id: ulid)
    if client
      ExternalSystemGlobalIdentity.find_or_create_by(
        external_system_id: ExternalSystem.first&.id,
        global_id: ulid,
        external_id: client.external_id,
        client_slug: client.slug,
        organization_name: Organization.current&.short_name
      )
    end
  end
end
