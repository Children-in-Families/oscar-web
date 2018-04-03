class RegistrationsController < Devise::RegistrationsController
  before_action :notify_user, :set_sidebar_basic_info, only: [:edit, :update]
  before_action :set_paper_trail_whodunnit

  def new
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def create
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  protected

  def update_resource(resource, params)
    if params[:program_warning].present? || params[:domain_warning].present?
      resource.update_without_password(params)
    else
      super
    end
  end

  def after_update_path_for(resource)
    if params[:user][:program_warning].present?
      flash[:notice] = nil
      program_streams_path
    elsif params[:user][:domain_warning].present?
      flash[:notice] = nil
      domains_path
    else
      super
    end
  end

  private

  def notify_user
    clients = Client.accessible_by(current_ability)
    @notification = UserNotification.new(current_user, clients)
  end

  def set_sidebar_basic_info
    @dashboard = Dashboard.new(current_user)
  end
end
