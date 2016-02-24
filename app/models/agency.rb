class Agency < ActiveRecord::Base
  has_and_belongs_to_many :clients

  validates :name, presence: true, uniqueness: true

  scope :name_like, -> (value) { where( "LOWER(agencies.name) LIKE '%#{value.downcase}%'") }

end
