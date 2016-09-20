class Intervention < ActiveRecord::Base
  validates :action, presence: true, uniqueness: true

  has_and_belongs_to_many :progress_notes
end
