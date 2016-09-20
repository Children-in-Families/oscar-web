class ProgressNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :location
  belongs_to :material
  belongs_to :progress_note_type

  has_and_belongs_to_many :interventions
end