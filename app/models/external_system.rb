class ExternalSystem < ActiveRecord::Base
  has_many :external_system_global_identities, class_name: 'ExternalSystemGlobalIdentity', foreign_key: 'global_id', dependent: :destroy

  validates :name, :token, presence: true

  def self.fetch_external_system_name(token)
    external_system = ExternalSystem.find_by(token: token)
    [external_system&.id, external_system&.name || '']
  end
end
