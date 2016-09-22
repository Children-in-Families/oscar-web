class Material < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :status, presence: true, uniqueness: true

  def has_no_any_progress_notes?
    progress_notes.count.zero?
  end
end
