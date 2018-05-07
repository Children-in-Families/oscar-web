class OrganizationType < ActiveRecord::Base
  has_many :partners, dependent: :restrict_with_error

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
