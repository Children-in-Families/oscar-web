class Location < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def has_no_any_progress_notes?
    progress_notes.count.zero?
  end

  def other_used
    name == 'ផ្សេងៗ Other' ? 1 : 0
  end
end
