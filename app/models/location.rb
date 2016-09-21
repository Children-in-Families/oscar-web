class Location < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
