class DomainGroup < ActiveRecord::Base
  include ActionView::Helpers

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

  def domain_name(custom=false)
    domain_identities = custom ? custom_domain_identities : default_domain_identities
    "Domain #{name} (#{domain_identities})"
  end
end
