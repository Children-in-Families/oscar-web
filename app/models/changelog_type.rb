class ChangelogType < ApplicationRecord
  belongs_to :changelog

  default_scope { order(:change_type) }

  validates :change_type, presence: true
  validates :description, presence: true, uniqueness: { scope: [:changelog_id, :change_type] }
end
