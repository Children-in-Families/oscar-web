class ProgressNoteType < ActiveRecord::Base
  validates :note_type, presence: true, uniqueness: true
end
