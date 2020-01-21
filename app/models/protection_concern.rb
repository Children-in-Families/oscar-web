class ProtectionConcern < ActiveRecord::Base
  has_many :client_protection_concerns, dependent: :destroy
  has_many :clients, through: :client_protection_concerns

  validates :content, presence: true, uniqueness: { case_sensitive: false }
end
