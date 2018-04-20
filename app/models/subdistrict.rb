class Subdistrict < ActiveRecord::Base
  belongs_to :district
  has_many :clients, dependent: :restrict_with_error
end
