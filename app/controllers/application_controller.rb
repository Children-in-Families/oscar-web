class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :find_association, if: :devise_controller?

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

end