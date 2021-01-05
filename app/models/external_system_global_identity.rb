class ExternalSystemGlobalIdentity < ApplicationRecord
  belongs_to :external_system
  belongs_to :global_identity, class_name: 'GlobalIdentity', foreign_key: 'global_id', primary_key: :ulid

  validates :organization_name, presence: true
  validates :global_id, presence: true
end
