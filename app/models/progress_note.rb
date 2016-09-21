class ProgressNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :location
  belongs_to :material
  belongs_to :progress_note_type
  belongs_to :user

  has_and_belongs_to_many :interventions
  has_and_belongs_to_many :assessment_domains

  validates :date, presence: true
end