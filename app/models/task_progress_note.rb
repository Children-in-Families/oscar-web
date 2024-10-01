class TaskProgressNote < ActiveRecord::Base
  belongs_to :task

  validates :progress_note, presence: :true
end
