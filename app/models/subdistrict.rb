class Subdistrict < ActiveRecord::Base
  belongs_to :district
  has_many :clients, dependent: :restrict_with_error

  validates :district, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:district_id] }
end
