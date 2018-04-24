class District < ActiveRecord::Base
  belongs_to :province
  has_many :clients, dependent: :restrict_with_error
  has_many :subdistricts, dependent: :destroy

  has_paper_trail

  validates :province, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:province_id] }
end
