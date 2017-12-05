class SettingsController < AdminController
  def country
    session[:country] ||= params[:country]
    flash[:notice] = session[:country] == params[:country] ? nil : t(".switched_country_#{params[:country]}")
    session[:country] = params[:country]
  end
end
