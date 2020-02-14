class DomainGroup < ActiveRecord::Base
  has_many :domains

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:id, :name) }

  def default_domain_identities
    if Organization.current.try(:aht) == true
      domains.csi_domains.map do |domain|
        domain_identity = I18n.t("dimensions.dimension_identies.#{domain.identity.strip.parameterize('_')}_#{domain.name.downcase}")
        domain_identity.gsub(/\(|\)/, '')
      end.join(', ')
    else
      domains.csi_domains.map do |domain|
        domain_identity = I18n.t("domains.domain_identies.#{domain.identity.strip.parameterize('_')}_#{domain.name.downcase}")
        domain_identity.gsub(/\(|\)/, '')
      end.join(', ')
    end
  end

  def custom_domain_identities
    domains.custom_csi_domains.map(&:identity).join(', ')
  end

  def first_ordered?
    name == DomainGroup.first.name
  end
end
