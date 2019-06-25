class DomainGroup < ActiveRecord::Base
  has_many :domains

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:id, :name) }

  def default_domain_identities
    domains.csi_domains.map(&:identity).map do |identity|
      domain_identity = I18n.t("domains.domain_identies.#{identity.strip.parameterize('_')}")
      domain_identity.gsub(/\(|\)/, '')
    end.join(', ')
  end

  def custom_domain_identities
    domains.custom_csi_domains.map(&:identity).join(', ')
  end

  def first_ordered?
    name == DomainGroup.first.name
  end

  def domain_name
    "Domain #{name} (#{default_domain_identities})"
  end
end
