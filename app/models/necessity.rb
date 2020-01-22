class Necessity < ActiveRecord::Base
  has_many :client_necessities, dependent: :destroy
  has_many :clients, through: :client_necessities

  validates :content, presence: true, uniqueness: { case_sensitive: false }
end
