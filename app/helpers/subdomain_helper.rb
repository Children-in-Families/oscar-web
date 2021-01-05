module SubdomainHelper
  def with_subdomain(subdomain)
    subdomain = (subdomain || '')
    subdomain += '.' unless subdomain.empty?
    host = Rails.application.config.action_mailer.default_url_options[:host]
    [subdomain, host].join
  end

  def url_for(options = {}, *params)
    if options.is_a?(Hash) && options.key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    # options = request.parameters
    super(options, *params)
  end
end
