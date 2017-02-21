class Donor < ActiveRecord::Base
	has_many :clients, dependent: :restrict_with_error

	has_paper_trail

	validates :name, presence:   true
	validates :name, uniqueness: true
end
