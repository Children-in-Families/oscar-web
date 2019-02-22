class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :find_association, if: :devise_controller?
  before_action :set_locale
  before_action :set_paper_trail_whodunnit, :current_setting

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: "#{Rails.root}/app/views/errors/404", layout: false, status: :not_found
  end

  helper_method :current_organization, :current_setting

  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to root_url, alert: exception.message
    if exception.subject.inspect.include?("Client") && (exception.action).to_s.include?("show")
      flash[:notice] = t('unauthorized.case_worker_unauthorized')
    else
      flash[:alert] = t('unauthorized.default')
    end
    redirect_to root_path
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    redirect_to root_path, alert: t('unauthorized.default')
  end

  def current_organization
    Organization.current
  end

  def current_setting
    @current_setting = Setting.first
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
    devise_parameter_sanitizer.for(:account_update) << :task_notify
    devise_parameter_sanitizer.for(:account_update) << :calendar_integration
    devise_parameter_sanitizer.for(:account_update) << :pin_code
    devise_parameter_sanitizer.for(:account_update) << :program_warning
    devise_parameter_sanitizer.for(:account_update) << :domain_warning
    devise_parameter_sanitizer.for(:account_update) << :gender
    # devise_parameter_sanitizer.for(:account_update) << :staff_performance_notification
    devise_parameter_sanitizer.for(:account_update) << :referral_notification
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
  end

  def set_locale
    locale = I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : I18n.locale if params[:locale].present?
    if detect_browser.present?
      flash.clear
      flash[:alert] = detect_browser
    end
    I18n.locale = locale || I18n.locale
  end

  def default_url_options(options = {})
    country = Setting.first.try(:country_name) || params[:country] || 'cambodia'
    { locale: I18n.locale, country: country }.merge(options)
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url(host: request.domain, subdomain: 'start')
  end

  def detect_browser
    lang = params[:locale] || locale.to_s
    if browser.firefox? && browser.platform.mac? && lang == 'km'
      "Khmer fonts for Firefox do not render correctly. Please use Google Chrome browser instead if you intend to use OSCaR in Khmer language."
    end
  end
end
