class ChangelogType < ActiveRecord::Base
  belongs_to :changelog

  default_scope { order(:change_type) }

  validates :change_type, :description, presence: true
end
