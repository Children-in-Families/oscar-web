class Intervention < ActiveRecord::Base
  validates :action, presence: true, uniqueness: true

  has_and_belongs_to_many :progress_notes

  scope :action_like, -> (values) { where('LOWER(interventions.action) ILIKE ANY ( array[?] )', values.map { |val| "%#{val.downcase}%" }) }

  def has_no_any_progress_notes?
    progress_notes.count.zero?
  end
end
