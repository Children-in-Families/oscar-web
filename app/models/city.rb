class City < ActiveRecord::Base
  belongs_to :province

  has_many :districts, dependent: :destroy

  validates :province, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:province_id] }
end
