class Changelog < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  has_many :changelog_types, dependent: :destroy

  default_scope { order(created_at: :desc) }

  accepts_nested_attributes_for :changelog_types, reject_if: :all_blank, allow_destroy: true

  validates :version, presence: true, uniqueness: true
  validates :user_id, presence: true
end
