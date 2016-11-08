class DomainGroup < ActiveRecord::Base
  has_many :domains

  has_paper_trail

  validates :name, presence: true, uniqueness: true

  default_scope { order('name') }

  def domain_identities
    domains.map(&:identity).join(', ')
  end
end
