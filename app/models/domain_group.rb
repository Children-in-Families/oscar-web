class DomainGroup < ActiveRecord::Base
  include ActionView::Helpers

  has_many :domains
  has_many :case_note_domain_groups

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:id, :name) }

  def default_domain_identities(custom_assessment_setting_id=nil)
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

  def custom_domain_identities(custom_assessment_setting_id=nil)
    if custom_assessment_setting_id
      domains.custom_csi_domains.where(custom_assessment_setting_id: custom_assessment_setting_id).map(&:identity).join(', ')
    else
      domains.custom_csi_domains.map(&:identity).join(', ')
    end
  end

  def first_ordered?
    name == DomainGroup.first.name
  end

  def domain_name(custom='false')
    domain_identities = custom == 'true' ? custom_domain_identities : default_domain_identities
    "Domain #{name} (#{domain_identities})"
  end
end
