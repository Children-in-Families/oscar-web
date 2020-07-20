class ExternalSystemGlobalIdentity < ActiveRecord::Base
  belongs_to :external_system
  belongs_to :global_identity, class_name: 'GlobalIdentity', foreign_key: 'ulid'

  validates :organization_name, presence: true
  validates :global_id, presence: true, uniqueness: { scope: [:external_id, :external_system_id] }
end
