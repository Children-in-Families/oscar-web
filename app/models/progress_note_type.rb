class ProgressNoteType < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  has_paper_trail

  validates :note_type, presence: true, uniqueness: true

  def has_no_any_progress_notes?
    progress_notes.count.zero?
  end
end
