class Referee < ActiveRecord::Base
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  has_many :clients

  # has_many :calls, dependent: :restrict_with_error

  # validates :answered_call, :called_before, presence: true
end
