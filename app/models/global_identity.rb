class GlobalIdentity < ActiveRecord::Base
  has_many :clients, class_name: 'Client', foreign_key: 'global_id', dependent: :restrict_with_error

  validates :ulid, presence: true, uniqueness: { case_sensitive: false }
end
