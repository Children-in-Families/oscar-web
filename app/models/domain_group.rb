class DomainGroup < ActiveRecord::Base
  has_many :domains

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:id, :name) }

  def default_domain_identities
    domains.csi_domains.map(&:identity).join(', ')
  end

  def custom_domain_identities
    domains.custom_csi_domains.map(&:identity).join(', ')
  end

  def first_ordered?
    name == DomainGroup.first.name
  end
end
