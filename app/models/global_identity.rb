class GlobalIdentity < ActiveRecord::Base
  has_many :clients

  validates :ulid, presence: true, uniqueness: { case_sensitive: false }
end
