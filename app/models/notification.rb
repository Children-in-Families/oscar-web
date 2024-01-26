class Notification < ActiveRecord::Base
  KEYS = %w(relase_note).freeze

  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates :key, presence: true, inclusion: { in: KEYS }
  validates :user, presence: true
  validates :notifiable, presence: true

  scope :relase_note, -> { where(key: 'relase_note') }
  scope :unread, -> { where(seen_at: nil) }
end
