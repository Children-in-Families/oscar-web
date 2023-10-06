class Notification < ActiveRecord::Base
  KEYS = %w(relase_note).freeze

  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates :key, presence: true, inclusion: { in: KEYS }
  validates :user, presence: true
  validates :notifiable, presence: true
end
