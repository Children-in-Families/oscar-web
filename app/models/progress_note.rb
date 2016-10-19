class ProgressNote < ActiveRecord::Base
  belongs_to :client
  belongs_to :location
  belongs_to :material
  belongs_to :progress_note_type
  belongs_to :user

  has_and_belongs_to_many :interventions
  has_and_belongs_to_many :assessment_domains

  validates :client_id, :user_id, :date, presence: true
  validates :other_location, presence: true, if: :is_other_location

  scope :other_location_like, -> (value) { where('LOWER(progress_notes.other_location) LIKE ?', "%#{value.downcase}%") }

  before_save :toggle_other_location

  def toggle_other_location
    if location_id.present? && !is_other_location
      self.other_location = ''
    else
      self.other_location = self.other_location
    end
  end

  def is_other_location
    other_location_id = Location.find_by(name: 'ផ្សេងៗ Other').id
    location_id == other_location_id
  end
end
