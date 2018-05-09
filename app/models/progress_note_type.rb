class ProgressNoteType < ActiveRecord::Base
  # has_many :progress_notes, dependent: :restrict_with_error
  #
  # has_paper_trail
  #
  # validates :note_type, presence: true, uniqueness: { case_sensitive: false }
end
