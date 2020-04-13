class GlobalIdentity < ActiveRecord::Base
  has_many :clients, dependent: :restrict_with_error

  validates :ulid, presence: true, uniqueness: { case_sensitive: false }
end
