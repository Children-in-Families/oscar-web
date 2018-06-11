class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.visible.order(:created_at)
    if user_signed_in?
      redirect_to dashboards_path(subdomain: Organization.current.short_name)
    else
      redirect_to root_url(subdomain: 'start') unless request.subdomain == 'start' || request.subdomain == 'mho'
    end
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
