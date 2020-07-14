class ExternalSystem < ActiveRecord::Base
  has_many :external_system_global_identities, class_name: 'ExternalSystemGlobalIdentity', foreign_key: 'global_id', dependent: :destroy

  validates :name, :token, presence: true
end
