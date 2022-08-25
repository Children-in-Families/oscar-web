module DomainHelper
  def translate_domain_header(domain)
    if I18n.locale == :km
      domain.local_description[/<strong>.*<\/strong>/].html_safe
    else
      "#{t('domains.domain_list.domains')} : #{domain.name} (#{domain.identity})"
    end
  end

  def mapping_domain_name_and_identity(domains)
    domains.map{ |domain| [translate_domain_header(domain), domain.id] }
  end

  def custom_domain_groups
    Domain.custom_csi_domains.group_by { |domain| domain.custom_assessment_setting_id }
  end
end
