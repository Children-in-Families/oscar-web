class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.cache_visible_ngos
    if user_signed_in?
      redirect_to dashboards_path(subdomain: Apartment::Tenant.current)
    else
      redirect_to root_url(subdomain: "start") unless request.subdomain == "start" || request.subdomain == "mho"
    end
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: "text/plain"
  end
end
