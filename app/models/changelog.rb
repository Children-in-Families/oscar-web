class Changelog < ActiveRecord::Base
  belongs_to :user, counter_cache: true

  default_scope { order(created_at: :desc) }

  validates :version, presence: true, uniqueness: true
  validates :user_id, :description, presence: true
end
