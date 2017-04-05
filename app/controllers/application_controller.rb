class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :find_association, if: :devise_controller?
  before_action :set_locale
  before_action :set_paper_trail_whodunnit

  helper_method :current_organiation

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def current_organiation
    Organization.current
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << :first_name
    devise_parameter_sanitizer.for(:account_update) << :last_name
    devise_parameter_sanitizer.for(:account_update) << :date_of_birth
    devise_parameter_sanitizer.for(:account_update) << :job_title
    devise_parameter_sanitizer.for(:account_update) << :department_id
    devise_parameter_sanitizer.for(:account_update) << :start_date
    devise_parameter_sanitizer.for(:account_update) << :province_id
    devise_parameter_sanitizer.for(:account_update) << :mobile
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
  end

  def set_locale
    locale = I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : I18n.locale if params[:locale].present?
    flash.clear
    flash[:alert] = browser_detection if browser_detection.present? && params[:locale] == 'km'
    I18n.locale = locale || I18n.locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

  def after_sign_in_path_for(_resource)
    dashboards_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url(host: request.domain)
  end

  def browser_detection
    result = request.env['HTTP_USER_AGENT']
    browser_compatible = ''
    if result =~ /Safari/
      unless result =~ /Chrome/
        version = result.split('Version/')[1].split(' ').first.split('.').first
        browser_compatible = "Application is not translated properly for Safari version's #{version}, please update your Safari." if version.to_i < 5
      else
        version = result.split('Chrome/')[1].split(' ').first.split('.').first
        browser_compatible = "Application is not translated properly for Google Chrome version's #{version}, please update your Google Chrome" if version.to_i < 15
      end
    elsif result =~ /Firefox/
      version = result.split('Firefox/')[1].split('.').first
      if os == 'Mac OS'
        browser_compatible = "Application is not translated properly for Firefox on Mac, we're sorry to suggest to use Google Chrome browser instead."
      elsif version.to_i < 15
        browser_compatible = "Application is not translated properly for Firefox version's #{version}, please update your Firefox."
      end
    end
    browser_compatible
  end

  def os
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /darwin|mac os/
        'Mac OS'
      end
    )
  end
end
