class TaskProgressNote < ApplicationRecord
  belongs_to :task

  validates :progress_note, presence: :true
end
