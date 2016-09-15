class Changelog < ActiveRecord::Base
  belongs_to :user, counter_cache: true

  default_scope { order(created_at: :desc) }

  validates :version, presence: true, uniqueness: true
  validates :description, presence: true
end
