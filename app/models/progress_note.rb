class ProgressNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :location
  belongs_to :material
  belongs_to :progress_note_type
  belongs_to :user

  has_and_belongs_to_many :interventions
  has_and_belongs_to_many :assessment_domains

  validates :client_id, :user_id, :date, presence: true

  scope :other_location_like, -> (value) { where('LOWER(progress_notes.other_location) LIKE ?', "%#{value.downcase}%") }
end
