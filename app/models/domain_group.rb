class DomainGroup < ActiveRecord::Base
  has_many :domains

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order('name') }

  def domain_identities
    domains.map(&:identity).join(', ')
  end

  def first_ordered?
    name == DomainGroup.first.name
  end
end
