class RegistrationsController < Devise::RegistrationsController
  before_action :notify_user, :set_sidebar_basic_info, only: [:edit, :update]
  before_action :set_paper_trail_whodunnit

  def new
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  def create
    redirect_to new_user_session_path, notice: 'Registrations are not allowed.'
  end

  private

  def notify_user
    @notification = UserNotification.new(current_user)
  end

  def set_sidebar_basic_info
    @dashboard = Dashboard.new(current_user)
  end
end
