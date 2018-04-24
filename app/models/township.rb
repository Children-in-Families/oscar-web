class Township < ActiveRecord::Base
  belongs_to :state
  has_many :clients, dependent: :restrict_with_error

  validates :state, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: [:state_id] }
end
