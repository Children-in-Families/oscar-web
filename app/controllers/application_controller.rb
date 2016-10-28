class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :find_association, if: :devise_controller?
  before_action :set_locale
  before_action :detect_browser
  before_action :user_notify

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
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
    I18n.locale = locale || I18n.locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

  def detect_browser
    render file: 'unsupported_browser', layout: false if browser.ie? || browser.edge?  || !browser.modern?
  end

  def user_notify
    @overdue_tasks   = Task.incomplete.overdue.of_user(current_user)
    @due_today_tasks = Task.incomplete.today.of_user(current_user)
    assessments      = current_user.assessment_either_overdue_or_due_today
    @overdue_assessments_count   = assessments[0]
    @due_today_assessments_count = assessments[1]
    @notification_count = (@overdue_tasks.count + @due_today_tasks.count + @overdue_assessments_count + @due_today_assessments_count)
  end
end
