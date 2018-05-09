class Intervention < ActiveRecord::Base
  # validates :action, presence: true, uniqueness: { case_sensitive: false }
  #
  # has_and_belongs_to_many :progress_notes
  #
  # has_paper_trail
  #
  # scope :action_like, ->(values) { where('interventions.action iLIKE ANY ( array[?] )', values.map { |val| "%#{val}%" }) }
end
