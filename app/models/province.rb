class Province < ActiveRecord::Base

  has_many :users
  has_many :families
  has_many :partner
  has_many :clients
  has_many :cases

  validates :name, presence: true, uniqueness: true
end
