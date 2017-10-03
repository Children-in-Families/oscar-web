class Interviewee < ActiveRecord::Base
  has_many :client_interviewees, dependent: :restrict_with_error
  has_many :clients, through: :client_interviewees

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
