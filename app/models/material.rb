class Material < ActiveRecord::Base
  has_many :progress_notes, dependent: :restrict_with_error

  validates :status, presence: true, uniqueness: true
end
