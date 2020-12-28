class DomainGroup < ApplicationRecord
  include ActionView::Helpers

  has_many :domains
  has_many :case_note_domain_groups, dependent: :destroy

  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:id, :name) }

  def default_domain_identities(custom_assessment_setting_id=nil)
    identities = Organization.current.try(:aht) == true ? "dimensions.dimension_identies" : "domains.domain_identies"
    domains.csi_domains.map do |domain|
      domain_identity = I18n.t("#{identities}.#{domain.identity.strip.parameterize.underscore}_#{domain.name.downcase}")
      domain_identity.gsub(/\(|\)/, '')
    end.join(', ')
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

  def domain_name(custom='false', custom_assessment_setting_id=nil)
    domain_identities = custom == 'true' ? custom_domain_identities(custom_assessment_setting_id) : default_domain_identities
    "Domain #{name} (#{domain_identities})"
  end
end
