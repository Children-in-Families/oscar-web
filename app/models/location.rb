class Location < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def has_no_any_progress_notes?
    progress_notes.count.zero?
  end

  def is_other?
    name == 'ផ្សេងៗ Other'
  end
end
