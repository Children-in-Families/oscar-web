module DomainHelper
  def translate_domain_header(domain)
    if I18n.locale == :km
      domain.local_description[/<strong>.*<\/strong>/].html_safe
    else
      "#{t('.domains')} : #{domain.name} (#{domain.identity})"
    end
  end

  def domain_translation_description(domain)
    domain.translate_description.html_safe
  end
end
