class Need < ActiveRecord::Base
  has_many :client_needs, dependent: :restrict_with_error
  has_many :clients, through: :client_needs

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
