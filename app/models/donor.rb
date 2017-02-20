class Donor < ActiveRecord::Base
	has_many :clients

	validates :name, presence: true
	validates :name, uniqueness: true
end
