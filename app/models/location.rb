class Location < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def other_used
    name == 'ផ្សេងៗ Other' ? 1 : 0
  end
end
