class Changelog < ActiveRecord::Base
  belongs_to :user, counter_cache: true

  validates :version, presence: true, uniqueness: true
  validates :description, presence: true
end
