class Necessity < ActiveRecord::Base
  has_many :client_necessities, dependent: :restrict_with_error
  has_many :clients, through: :client_necessities

  validates :content, presence: true, uniqueness: { case_sensitive: false }
end
