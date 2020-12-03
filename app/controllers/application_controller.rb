class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :null_session, except: :index, if: proc { |c| c.request.format == 'application/json' }
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :find_association, if: :devise_controller?
  before_action :set_locale, :override_translation
  before_action :set_paper_trail_whodunnit, :current_setting
  before_action :prevent_routes
  before_action :set_raven_context

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render file: "#{Rails.root}/app/views/errors/404", layout: false, status: :not_found
  end

  helper_method :current_organization, :current_setting
  helper_method :field_settings

  rescue_from CanCan::AccessDenied do |exception|
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

  def field_settings
    @field_settings ||= FieldSetting.where('for_instances IS NULL OR for_instances iLIKE ?', "#{current_organization.short_name}")
  end

  def pundit_user
    UserContext.new(current_user, field_settings)
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
    devise_parameter_sanitizer.for(:account_update) << :preferred_language
    devise_parameter_sanitizer.for(:account_update) << :referral_notification
  end

  def find_association
    @department = Department.order(:name)
    @province   = Province.order(:name)
  end

  def set_locale
    locale = I18n.locale
    locale = current_user.preferred_language if user_signed_in?
    locale = params[:locale] if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)

    if detect_browser.present?
      flash.clear
      flash[:alert] = detect_browser
    end

    I18n.locale = locale
  end

  def override_translation
    I18n.backend.reload! if request.get? && request.format.html?
  end

  def default_url_options(options = {})
    country = Setting.first.try(:country_name) || params[:country] || 'cambodia'
    { locale: I18n.locale, country: country }.merge(options)
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url(host: request.domain, subdomain: 'start')
  end

  def after_sign_in_path_for(_resource_or_scope)
    stored_location_for(_resource_or_scope) || super ||  dashboards_path(locale: current_user&.preferred_language || 'en')
  end

  def detect_browser
    lang = params[:locale] || locale.to_s
    if browser.firefox? && browser.platform.mac? && lang == 'km'
      "Khmer fonts for Firefox do not render correctly. Please use Google Chrome browser instead if you intend to use OSCaR in Khmer language."
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def prevent_routes
    if current_setting.try(:enable_hotline) == false && params[:controller] == "calls"
      redirect_to root_path, notice: t('unauthorized.you_cannot_access_this_page')
    elsif current_setting.try(:enable_client_form) == false && params[:controller] == "clients"
      redirect_to root_path, notice: t('unauthorized.you_cannot_access_this_page')
    end
  end

  def set_raven_context
    Raven.tags_context(
      language: I18n.locale
    )
    if current_user
      Raven.user_context(id: current_user.id, organization: Apartment::Tenant.current)
    else
      Raven.user_context(ip: request.ip)
    end
  end
end
